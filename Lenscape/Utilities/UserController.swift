//
//  UserController.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 4/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import Foundation
import os.log

class UserController {
    static let userDefaults = UserDefaults.standard
    
    static func saveUser(user: [String: Any]) -> Bool {
        userDefaults.set(user, forKey: "user")
        return true
    }
    
    static func getCurrentUser() -> [String: Any]? {
        guard let cu = userDefaults.dictionary(forKey: "user") else {
            os_log("No user found in UserDefaults", log: .default, type: .debug)
            return nil
        }
        return cu
    }
    
    static func getToken() -> String {
        let cu = getCurrentUser()!
        guard let token = cu["token"] else {
            fatalError("No token found in user: \(cu)")
        }
        return token as! String
    }
    
    static func signout() {
        userDefaults.removeObject(forKey: "user")
    }
}
