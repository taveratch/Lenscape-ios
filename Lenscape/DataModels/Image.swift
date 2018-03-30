//
//  Image.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 19/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import Foundation
import UIKit

struct Image {
    var title: String?
    var type: String?
    var id: String?
    var width: Int?
    var height: Int?
    var link: String?
    var thumbnailLink: String?
    var datetime: Int64?
    var location: Location?
    
    private func getImageUrlFromType(type: String = "t", link: String) -> String {
        let index = link.index(link.endIndex, offsetBy: -4)
        return "\(link[..<index])\(type)\(link[index...])"
    }
    
    init(item: Any) {
        guard let image = item as? [String: Any] else {
            fatalError("\(item) is not instance of dictionary [String: Any]")
        }
        title = image["name"] as? String ?? "Image name"
        type = image["type"] as? String
        id = image["id"] as? String
//        width = image["width"] as? Int
//        height = image["height"] as? Int
        link = image["original_link"] as? String
//        datetime = image["datetime"] as? Int64
        thumbnailLink = image["thumbnail_link"] as? String
        
        //TODO: Change this
        let locationObject = image["location"] as! [String: Any]
        location = Location(latitude: locationObject["latitude"] as! Double, longitude: locationObject["longitude"] as! Double)
    }
    
    private func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}
