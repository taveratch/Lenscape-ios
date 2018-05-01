//
//  Notification.swift
//  Lenscape
//
//  Created by Thongrapee Panyapatiphan on 23/4/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import Foundation

class NotificationItem: NSObject, NSCoding {

    var title: String?
    var body: String?
    var deliveredTime: TimeInterval?
    var photoId: String?
    
    init(title: String, body: String, photoId: String? = nil) {
        self.title = title
        self.body = body
        self.photoId = photoId
        self.deliveredTime = Date().timeIntervalSince1970*1000
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: "title")
        aCoder.encode(body, forKey: "body")
        aCoder.encode(deliveredTime, forKey: "deliveredTime")
        aCoder.encode(photoId, forKey: "photoId")
    }
    
    required init?(coder aDecoder: NSCoder) {
        title = aDecoder.decodeObject(forKey: "title") as? String
        body = aDecoder.decodeObject(forKey: "body") as? String
        deliveredTime = aDecoder.decodeObject(forKey: "deliveredTime") as? TimeInterval
        photoId = aDecoder.decodeObject(forKey: "photoId") as? String
    }
    
}
