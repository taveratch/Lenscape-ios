//
//  SearchResult.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 9/4/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import Foundation
import GooglePlaces

struct SearchResult {
    var name: String!
    var address: String!
    var placeID: String!
    
    init(prediction: GMSAutocompletePrediction) {
        name = prediction.attributedPrimaryText.string
        address = prediction.attributedSecondaryText?.string
        placeID = prediction.placeID!
    }
}
