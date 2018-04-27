//
//  DistanceUtil.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 25/4/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import Foundation

class DistanceUtil {
    static func getProperDistanceFormat(distanceKM: Double?) -> String {
        if distanceKM == nil {
            return ""
        }
        if distanceKM! < 1 {
            return "\(Int(ceil(distanceKM! * 1000))) m"
        } else {
            return "\(String(format: "%.2f", distanceKM!)) km"
        }
    }
}
