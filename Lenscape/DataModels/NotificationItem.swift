//
//  Notification.swift
//  Lenscape
//
//  Created by Thongrapee Panyapatiphan on 23/4/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import Foundation

class NotificationItem {
    var title: String?
    var body: String?
    var deliveredTime: TimeInterval?
    var isRead: Bool = false
    
    init(title: String, body: String) {
        self.title = title
        self.body = body
        deliveredTime = Date().timeIntervalSince1970*1000
    }
}
