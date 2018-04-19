//
//  ExploreMapViewControllerDelegate.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 19/4/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import Foundation

protocol ExploreMapViewControllerDelegate {
    func didMapChangeLocation(location: Location, locationName: String?)
    func didUpdateLocationName(locationName: String)
}
