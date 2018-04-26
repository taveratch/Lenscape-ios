//
//  Place.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 16/4/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import Foundation

class PlaceType {
    static let GOOGLE_TYPE = "google"
    static let LENSCAPE_TYPE = "lenscape"
}

struct Place: Codable, Hashable {
    var name: String
    var location: Location!
    var placeID: String = ""
    var hashValue: Int { get { return placeID.hashValue } }
    var type: String = PlaceType.LENSCAPE_TYPE
    var address: String = ""
    var distanceKM: Double?
    var images: [Image] = []
    
    init(name: String, location: Location) {
        self.name = name
        self.location = location
    }
    
    init(item: Any) {
        guard let place = item as? [String: Any] else {
            fatalError("place is not an instance of [String: Any]")
        }
        
        if let id = place["id"] as? Int {
            placeID = String(id)
        }else if let id = place["id"] as? String {
            placeID = id
        }
        
        let lat = place["latitude"] as! Double
        let long = place["longitude"] as! Double
        location = Location(latitude: lat, longitude: long)
        
        name = place["name"] as! String
        let isGooglePlace = place["is_google_place"] as! Bool
        type = isGooglePlace ? PlaceType.GOOGLE_TYPE : PlaceType.LENSCAPE_TYPE
        address = place["address"] as? String ?? ""
        
        distanceKM = place["distance"] as? Double
        
        if let imagesObj = place["photos"] as? [Any] {
            let images = imagesObj.map { Image(item: $0)}
            self.images = images
        }
        
    }
}

func ==(left: Place, right: Place) -> Bool {
    return left.placeID == right.placeID
}
