//
//  Image.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 19/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import Foundation
import UIKit

class Image: Codable {
    var name: String?
    var type: String?
    var id: Int
    var width: Int?
    var height: Int?
    var link: String?
    var thumbnailLink: String?
    var datetime: Int64!
    var relativeDatetimeString: String!
    var dateString: String
    var timeString: String
    var dateTaken: Int64
    var dateTakenString: String
    var partOfDayString: String
    var seasonString: String
    var distance: Double?
    var likes: Int?
    var owner: Owner!
    var isNear: Bool?
    var place: Place
    var is_liked: Bool
    var isOwner: Bool
    
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
        id = image["id"] as! Int
        likes = image["number_of_likes"] as? Int
        
        let ownerObj = image["owner"] as Any
        owner = Owner(item: ownerObj)
        
        link = image["original_url"] as? String
        thumbnailLink = image["thumbnail_link"] as? String
        
        let locationObject = image["location"] as! [String: Any]
        let location = Location(latitude: locationObject["latitude"] as! Double, longitude: locationObject["longitude"] as! Double)
        let locationName = locationObject["name"] as! String
        place = Place(name: locationName, location: location)
        place.placeID = locationObject["id"] as? String ?? String(locationObject["id"] as! Int)
        place.type = locationObject["is_google_place"] as! Bool ? PlaceType.GOOGLE_TYPE : PlaceType.LENSCAPE_TYPE
        
        distance = locationObject["distance"] as? Double ?? 0
        isNear = locationObject["is_near"] as? Bool
        
        datetime = image["timestamp"] as? Int64
        relativeDatetimeString = DateUtil.getRelativeTimeString(since: Double(datetime))
        (dateString, timeString) = DateUtil.getDateTimeString(of: Double(datetime))
        
        dateTaken = image["date_taken"] as! Int64
        dateTakenString = image["date_taken_string"] as! String
        
        partOfDayString = image["time_taken"] as! String
        seasonString = image["season"] as! String
        
        is_liked = image["is_liked"] as? Bool ?? false
        isOwner = image["is_owner"] as? Bool ?? false
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
