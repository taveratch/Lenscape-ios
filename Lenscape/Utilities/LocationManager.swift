//
//  LocationManager.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 25/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import Foundation

class LocationManager {
    
    var currentLocation: Location?
    private static var instance: LocationManager?
    
    static func getInstance() -> LocationManager {
        if instance == nil {
            instance = LocationManager()
        }
        return instance!
    }
    
    func setCurrentLocation(lat: Double, long: Double) {
        self.currentLocation = Location(latitude: lat, longitude: long)
    }
    
    func getCurrentLocation() -> Location? {
        return currentLocation
    }
}
