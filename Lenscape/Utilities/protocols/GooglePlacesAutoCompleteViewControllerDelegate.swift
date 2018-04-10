//
//  GooglePlacesAutoCompleteViewControllerDelegate.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 10/4/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import Foundation
import GooglePlaces

protocol GooglePlacesAutoCompleteViewControllerDelegate {
    func didSelectPlace(place: GMSPlace)
}
