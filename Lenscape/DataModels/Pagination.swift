//
//  Pagination.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 30/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import Foundation

class Pagination {
    var page: Int = 0
    var size: Int = 0
    var first: Int = 0
    var last: Int = 0
    var totalNumberOfPage: Int = 0
    var totalNumberOfEntities: Int = 0
    var hasMore = false
    
    init(pagination: [String: Any]?) {
        guard pagination != nil else {
            fatalError("Pagination object is nil")
        }
        
        page = getValue(in: pagination, key: "page_information.number")
        size = getValue(in: pagination, key: "page_information.size")
        first = getValue(in: pagination, key: "first")
        last = getValue(in: pagination, key: "last")
        totalNumberOfPage = getValue(in: pagination, key: "total_number_of_page")
        totalNumberOfEntities = getValue(in: pagination, key: "total_number_of_entities")
        hasMore = page < totalNumberOfPage
    }
    
    private func getValue(in pagination: [String: Any]?, key: String) -> Int {
        guard pagination != nil else {
            fatalError("Pagination object is nil")
        }
        if let p: Int? = pagination!.valueForKeyPath(keyPath: key) {
            return p!
        } else {
            let pString:String = pagination!.valueForKeyPath(keyPath: key)!
            return Int(pString)!
        }
    }
}
