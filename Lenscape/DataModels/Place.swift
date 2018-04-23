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
    
    init(name: String, location: Location) {
        self.name = name
        self.location = location
    }
}

func ==(left: Place, right: Place) -> Bool {
    return left.placeID == right.placeID
}
