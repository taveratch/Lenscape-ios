//
//  AddNewPlaceViewController.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 15/4/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class AddNewPlaceViewController: UIViewController {
    
    // MARK: - UI Components
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var placeNameTextField: UITextField!
    
    // MARK: - Attributes
    private let locationManager = CLLocationManager()
    private var placeMarker: GMSMarker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        placeNameTextField.delegate = self
        mapView.delegate = self
        
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.settings.zoomGestures = true
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Automatically show keyboard
        placeNameTextField.becomeFirstResponder()
    }
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        // Hide keyboard
        placeNameTextField.resignFirstResponder()
        
        dismiss(animated: true)
    }
    
    private func cameraTo(coordinate: CLLocationCoordinate2D) {
        mapView.camera = GMSCameraPosition(target: coordinate, zoom: 17, bearing: 0, viewingAngle: 0)
    }
    
    private func updateMarkerLocation(location: CLLocationCoordinate2D) {
        if placeMarker == nil {
            placeMarker = GMSMarker(position: location)
            placeMarker?.map = mapView
            placeMarker?.appearAnimation = .pop
        }else {
            placeMarker?.position = location
        }
    }
    
}

extension AddNewPlaceViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Hide keyboard when touch outside textfields
        self.view.endEditing(true)
    }
}

extension AddNewPlaceViewController: CLLocationManagerDelegate {
    
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
        
        updateMarkerLocation(location: location.coordinate)
        setupMapView(location: location)
        
        locationManager.stopUpdatingLocation()
    }
}

extension AddNewPlaceViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
//        print(position.target)
        updateMarkerLocation(location: position.target)
    }
}
