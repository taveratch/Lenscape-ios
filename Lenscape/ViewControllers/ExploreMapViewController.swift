//
//  ExploreMapViewController.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 9/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

//https://www.raywenderlich.com/179565/google-maps-ios-sdk-tutorial-getting-started

import UIKit
import GoogleMaps
import PromiseKit

class ExploreMapViewController: UIViewController, GMUClusterManagerDelegate, GMSMapViewDelegate {
    
    // MARK: - UI Components
    @IBOutlet weak var mapView: GMSMapView!
    
    // MARK: - Attributes
    private let locationManager = CLLocationManager()
    private var clusterManager: GMUClusterManager!

    // MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.settings.zoomGestures = true
        
        // Set up the cluster manager with the supplied icon generator and
        // renderer.
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView,
                                                 clusterIconGenerator: iconGenerator)
        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm,
                                           renderer: renderer)
        
        clusterManager.setDelegate(self, mapDelegate: self)
    }
    
    // Generate cluster item from api
    private func generateClusterItems(location: Location) -> Promise<[POIItem]> {
        var poiItems: [POIItem] = []
        return Promise {
            seal in
            Api.fetchExploreImages(location: location).done {
                fulfill in
                let images = fulfill["images"] as! [Image]
                for image in images {
                    poiItems.append(POIItem(position: CLLocationCoordinate2D(latitude: (image.location?.latitude)!, longitude: (image.location?.longitude)!), name: image.title!))
                }
                seal.fulfill(poiItems)
                }.catch{
                    error in
                    print(error)
                    seal.reject(error)
            }
        }
    }
    
    /// Returns a random value between -1.0 and 1.0.
    private func randomScale() -> Double {
        return Double(arc4random()) / Double(UINT32_MAX) * 2.0 - 1.0
    }
    
    @IBAction func back(_ sender: UIButton) {
        let explorePageVC = self.parent as? ExplorePageViewController
        explorePageVC!.setViewControllers([(explorePageVC!.views.first)!], direction: .reverse, animated: true, completion: nil)
    }
    
    // MARK: - GMUClusterManagerDelegate
    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
        let newCamera = GMSCameraPosition.camera(withTarget: cluster.position,
                                                           zoom: mapView.camera.zoom + 1)
        let update = GMSCameraUpdate.setCamera(newCamera)
        mapView.moveCamera(update)
        
        return false
    }
    
    // MARK: - GMUMapViewDelegate
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let poiItem = marker.userData as? POIItem {
            NSLog("Did tap marker for cluster item \(poiItem.name)")
        } else {
            NSLog("Did tap a normal marker")
        }
        return false
    }
}

// MARK: - CLLocationManagerDelegate

extension ExploreMapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else {
            return
        }
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        
        print("Did update Location")
        mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        
        //Add item to cluster
        generateClusterItems(location: Location(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)).done {
            poiItems in
            
            self.clusterManager.clearItems()
            
            for item in poiItems {
                self.clusterManager.add(item)
            }
            
            // Call cluster() after items have been added to perform the clustering
            // and rendering on map.
            self.clusterManager.cluster()
            }.catch {
                error in
                print(error)
        }
        locationManager.stopUpdatingLocation()
    }
    
}
