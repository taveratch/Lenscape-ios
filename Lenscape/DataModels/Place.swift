//
//  Place.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 16/4/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import Foundation

struct Place {
    var name: String!
    var location: Location!
    var placeID: String = ""
    
    init(name: String, location: Location) {
        self.name = name
        self.location = location
    }
}
