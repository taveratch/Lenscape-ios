//
//  ArchiveUtils.swift
//  Lenscape
//
//  Created by Thongrapee Panyapatiphan on 1/5/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import Foundation

class ArchiveUtil {
    
    private static let Key = "notifications"
    
    private static func archiveNotifications(notifications : [NotificationItem]) -> NSData {
        return NSKeyedArchiver.archivedData(withRootObject: notifications as NSArray) as NSData
    }
    
    static func loadNotifications() -> [NotificationItem]? {
        
        if let unarchivedObject = UserDefaults.standard.object(forKey: Key) as? Data {
            return NSKeyedUnarchiver.unarchiveObject(with: unarchivedObject as Data) as? [NotificationItem]
        }
        
        return []
    }
    
    static func saveNotifications(notifications : [NotificationItem]?) {
        let archivedObject = archiveNotifications(notifications: notifications!)
        UserDefaults.standard.set(archivedObject, forKey: Key)
        UserDefaults.standard.synchronize()
    }
    
    static func clearNotifications() {
        UserDefaults.standard.removeObject(forKey: Key)
    }
    
}
