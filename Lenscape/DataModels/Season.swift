//
//  Season.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 24/4/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import Foundation

struct Season {
    var id: Int
    var name: String
    
    init(item: Any) {
        guard let season = item as? [String: Any] else {
            fatalError("\(item) is not instance of dictionary [String: Any]")
        }
        guard let id = season["id"] as? Int else {
            fatalError("id is missing")
        }
        guard let name = season["name"] as? String else {
            fatalError("name is missing")
        }
        
        self.id = id
        self.name = name
    }
}
