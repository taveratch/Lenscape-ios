//
//  PartOfDay.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 24/4/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import Foundation

struct PartOfDay {
    var id: Int
    var name: String
    
    init(item: Any) {
        guard let partOfDay = item as? [String: Any] else {
            fatalError("\(item) is not instance of dictionary [String: Any]")
        }
        guard let id = partOfDay["id"] as? Int else {
            fatalError("id is missing")
        }
        guard let name = partOfDay["name"] as? String else {
            fatalError("name is missing")
        }
        
        self.id = id
        self.name = name
    }
}
