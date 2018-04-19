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
import GooglePlaces
import PromiseKit
import Hero

class ExploreMapViewController: UIViewController, GMUClusterManagerDelegate {
    
    // MARK: - UI Components
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var searchButton: UIView!
    @IBOutlet weak var seeInFeedButton: UIView!
    
    // MARK: - Attributes
    private let locationManager = CLLocationManager()
    private var clusterManager: GMUClusterManager!

    // MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchButton()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.settings.zoomGestures = true
        
        // Set up the cluster manager with the supplied icon generator and
        // renderer.
        let iconGenerator = CustomGMUClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = CustomClusterRenderer(mapView: mapView,
                                                 clusterIconGenerator: iconGenerator)
        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm,
                                           renderer: renderer)
        
        clusterManager.setDelegate(self, mapDelegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ComponentUtil.fade(of: seeInFeedButton, hidden: true)
    }
    private func setupSearchButton() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(showGMSAutoCompleteViewController))
        searchButton.addGestureRecognizer(tap)
        searchButton.isUserInteractionEnabled = true
        searchButton.hero.id = "searchViewWrapper"
    }
    
    @objc private func showGMSAutoCompleteViewController() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: Identifier.GooglePlacesAutoCompleteViewController.rawValue) as! GooglePlacesAutoCompleteViewController
        vc.delegate = self
        Hero.shared.defaultAnimation = .fade
        present(vc, animated: true)
    }
    
    // Generate cluster item from api
    private func generateClusterItems(location: Location) -> Promise<[POIItem]> {
        var poiItems: [POIItem] = []
        return Promise {
            seal in
            Api.fetchExploreImages(location: location, size: Constants.MAX_FETCHED_ITEM_MAP).done {
                fulfill in
                let images = fulfill["images"] as! [Image]
                for image in images {
                    poiItems.append(POIItem(position: CLLocationCoordinate2D(latitude: (image.location?.latitude)!, longitude: (image.location?.longitude)!), name: image.name!, image: image))
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
        Hero.shared.defaultAnimation = .zoom
        dismiss(animated: true)
    }
    
    // Tap on cluster marker
    // MARK: - GMUClusterManagerDelegate
    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
        if let items = cluster.items as? [POIItem] {
//            print(items[0].image)
        }
        
        return false
    }
    
    private func cameraTo(coordinate: CLLocationCoordinate2D) {
        mapView.camera = GMSCameraPosition(target: coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
    }
    
    private func setupMapView(location: CLLocation) {
        cameraTo(coordinate: location.coordinate)
        
        let styleName = "flat-pale-map-style"
        // use custom map style
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: styleName, withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find \(styleName).json")
            }
        } catch {
            NSLog("The style definition could not be loaded: \(error)")
        }
    }
    
    private func setupCluster(coordinate: CLLocationCoordinate2D) {
        //Add item to cluster
        generateClusterItems(location: Location(latitude: coordinate.latitude, longitude: coordinate.longitude)).done {
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
    }
    
    private func showMarker(place: Place) {
        let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: place.location.latitude, longitude: place.location.longitude))
        marker.title = place.name
        marker.appearAnimation = .pop
        marker.map = mapView
    }
    
}

// MARK: - CLLocationManagerDelegate

extension ExploreMapViewController: CLLocationManagerDelegate {
    
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
        
        // Update location in LocationManager
        LocationManager.getInstance().setCurrentLocation(lat: location.coordinate.latitude, long: location.coordinate.longitude)
        
        setupMapView(location: location)
        setupCluster(coordinate: location.coordinate)
        
        locationManager.stopUpdatingLocation()
    }
}

extension ExploreMapViewController: GooglePlacesAutoCompleteViewControllerDelegate {
    func didSelectPlace(place: Place) {
        let coordinate = CLLocationCoordinate2D(latitude: place.location.latitude, longitude: place.location.longitude)
        cameraTo(coordinate: coordinate)
        setupCluster(coordinate: coordinate)
        mapView.clear() //remove all markers
        showMarker(place: place)
    }
}

extension ExploreMapViewController: GMSMapViewDelegate {
    // MARK: - GMUMapViewDelegate
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        ComponentUtil.fade(of: seeInFeedButton, hidden: true)
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let poiItem = marker.userData as? POIItem {
            NSLog("Did tap marker for cluster item \(poiItem.name)")
        } else {
            NSLog("Did tap a normal marker")
        }
        return false
    }
    
    //When user end draging map
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        ComponentUtil.fade(of: seeInFeedButton, hidden: false)
        setupCluster(coordinate: position.target)
    }
}
