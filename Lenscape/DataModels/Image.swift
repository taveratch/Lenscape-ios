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
    var name: String?
    var type: String?
    var id: String?
    var width: Int?
    var height: Int?
    var link: String?
    var thumbnailLink: String?
    var datetime: Int64?
    var distance: Double?
    var likes: Int?
    var owner: Owner!
    var isNear: Bool?
    var location: Location?
    var locationName: String?
    
    private func getImageUrlFromType(type: String = "t", link: String) -> String {
        let index = link.index(link.endIndex, offsetBy: -4)
        return "\(link[..<index])\(type)\(link[index...])"
    }
    
    init(item: Any) {
        guard let image = item as? [String: Any] else {
            fatalError("\(item) is not instance of dictionary [String: Any]")
        }
        name = image["name"] as? String ?? "Image name"
        type = image["type"] as? String
        id = image["id"] as? String
        likes = image["number_of_like"] as? Int
        
        let ownerObj = image["Owner"] as! Any
        owner = Owner(item: ownerObj)
        
        link = image["original_link"] as? String
        thumbnailLink = image["thumbnail_link"] as? String
        
        //TODO: Change this
        let locationObject = image["location"] as! [String: Any]
        location = Location(latitude: locationObject["latitude"] as! Double, longitude: locationObject["longitude"] as! Double)
        locationName = locationObject["name"] as! String
        distance = locationObject["distance"] as? Double ?? 0
        isNear = locationObject["is_near"] as? Bool
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
