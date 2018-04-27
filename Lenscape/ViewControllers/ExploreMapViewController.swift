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
    var delegate: ExploreMapViewControllerDelegate?
    var currentMapViewLocation: Location?
    private var currentMapViewPlace: Place?
    var placesClient: GMSPlacesClient?
    var images: [Image] = []

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
        
        placesClient = GMSPlacesClient()
        
        addTapGesture(for: seeInFeedButton, with: #selector(seeInFeed))
        
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
        addTapGesture(for: searchButton, with: #selector(showGMSAutoCompleteViewController))
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
                self.images = images
                for image in images {
                    poiItems.append(POIItem(position: CLLocationCoordinate2D(latitude: image.place
                        .location.latitude, longitude: image.place.location.longitude), name: image.name!, image: image))
                }
                seal.fulfill(poiItems)
                }.catch {
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
    
    private func dismissView() {
        Hero.shared.defaultAnimation = .zoom
        dismiss(animated: true)
    }
 
    @IBAction func back(_ sender: UIButton) {
        dismissView()
    }
    
    @objc private func seeInFeed() {
        if delegate == nil || currentMapViewLocation == nil {
            return
        }
        var locationName: String? = nil
        
        // If marker in still on the map, assume that marker's name should be header text for Feed
        if let place = currentMapViewPlace, isMarkerWithinScreen(markerLocation: place.location) {
            locationName = "Around \(place.name)"
        } else if isMarkerWithinScreen(markerLocation: LocationManager.getInstance().getCurrentLocation()!) {
            // If user's current location is still on the map, assume that photos are from around you
            locationName = "Around You"
        } else if images.count > 0 { //If there are photos from fetching api, pick location's name from first photo
            locationName = "Around \(images.first!.place.name)"
        }
        
        delegate?.didMapChangeLocation(location: currentMapViewLocation!, locationName: locationName)
//        if locationName == nil {
//            getLikelihoodPlace().done {
//                likelihoodPlaces in
//                self.delegate?.didUpdateLocationName(locationName: likelihoodPlaces.first!.name)
//                }.catch{
//                    error in
//            }
//        }
        dismissView()
    }
    
    private func getLikelihoodPlace() -> Promise<[GMSPlace]> {
        return Promise {
            seal in
            placesClient?.currentPlace() {
                placeLikelihoods, error in
                if let error = error {
                    seal.reject(error)
                    return
                }
                // Get likely places and add to the list.
                if let likelihoodList = placeLikelihoods {
                    seal.fulfill(likelihoodList.likelihoods.map { return $0.place })
                }
            }
        }
    }
    
    // Tap on cluster marker
    // MARK: - GMUClusterManagerDelegate
    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
        if let items = cluster.items as? [POIItem] {
            let places = items.map { $0.image.place }
            let placesWithoutDuplicate = Array(Set<Place>(places))
            showPlaceListViewController(places: placesWithoutDuplicate)
        }
        
        return false
    }
    
    private func cameraTo(coordinate: Location) {
        mapView.camera = GMSCameraPosition(target: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude), zoom: 15, bearing: 0, viewingAngle: 0)
    }
    
    private func isMarkerWithinScreen(markerLocation: Location) -> Bool {
        let region = self.mapView.projection.visibleRegion()
        let bounds = GMSCoordinateBounds(region: region)
        return bounds.contains(CLLocationCoordinate2D(latitude: markerLocation.latitude, longitude: markerLocation.longitude))
    }
    
    private func setupMapView(location: Location) {
        cameraTo(coordinate: location)
        
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
    
    private func setupCluster(coordinate: Location) {
        //Add item to cluster
        generateClusterItems(location: coordinate).done {
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
        
        if currentMapViewLocation == nil {
            currentMapViewLocation = Location(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
        setupMapView(location: currentMapViewLocation!)
        setupCluster(coordinate: currentMapViewLocation!)
        
        
        locationManager.stopUpdatingLocation()
    }
}

extension ExploreMapViewController: GooglePlacesAutoCompleteViewControllerDelegate {
    func didSelectPlace(place: Place) {
        currentMapViewPlace = place
        let coordinate = CLLocationCoordinate2D(latitude: place.location.latitude, longitude: place.location.longitude)
        cameraTo(coordinate: place.location)
        setupCluster(coordinate: place.location)
        mapView.clear() //remove all markers
        showMarker(place: place)
    }
}

extension ExploreMapViewController: GMSMapViewDelegate {
    // MARK: - GMUMapViewDelegate
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        ComponentUtil.fade(of: seeInFeedButton, hidden: true)
    }
    
    private func showPlaceListViewController(places: [Place]) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: Identifier.PlaceListViewController.rawValue) as! PlaceListViewController
        vc.places = places
        let navigationController = UINavigationController(rootViewController: vc)
        Hero.shared.defaultAnimation = .push(direction: .left)
        present(navigationController, animated: true)
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let poiItem = marker.userData as? POIItem {
            NSLog("Did tap marker for cluster item \(poiItem.name)")
        } else {
            NSLog("Did tap a normal marker")
        }
        return false
    }
    
    //When user end draging map and when map is initialized
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        currentMapViewLocation = Location(latitude: position.target.latitude, longitude: position.target.longitude)
        ComponentUtil.fade(of: seeInFeedButton, hidden: false)
        setupCluster(coordinate: currentMapViewLocation!)
    }
}


// isMarkerWithinScreen
// https://stackoverflow.com/questions/30065098/google-maps-for-ios-how-can-you-tell-if-a-marker-is-within-the-bounds-of-the-s
