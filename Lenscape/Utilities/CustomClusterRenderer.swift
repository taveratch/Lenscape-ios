//
//  CustomClusterRenderer.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 1/4/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import Foundation
import UIKit

class CustomClusterRenderer: GMUDefaultClusterRenderer {
    
    let GMUAnimationDuration: Double = 0.5
    var mapView: GMSMapView?
    
    override init(mapView: GMSMapView, clusterIconGenerator iconGenerator: GMUClusterIconGenerator) {
        super.init(mapView: mapView, clusterIconGenerator: iconGenerator)
        self.mapView = mapView
    }
    
    // Should render cluster icon (group) or individual marker
    override func shouldRender(as cluster: GMUCluster, atZoom zoom: Float) -> Bool {
        return zoom <= 22;
    }
}
