//
//  UserController.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 4/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import Foundation
import PromiseKit
import os.log

class UserController {
    
    static let fb = FacebookLogin()
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
    
    static func signOut() {
        userDefaults.removeObject(forKey: "user")
        fb.logOut()
    }
    
    static func convertFBtoNormal(facebookUserData: [String: Any]) -> [String: Any] {
        let image: String = facebookUserData.valueForKeyPath(keyPath: "picture.data.url")!
        return [
            "name": facebookUserData["name"] as! String,
            "id": facebookUserData["id"] as! String,
            "profilePicture": image
        ]
    }
    
    //Todo: Checking token with server
    static func isLoggedIn() -> Promise<Bool>{
        return Promise {
            seal in
            if let _ = getCurrentUser() {
                seal.fulfill(true)
            }else {
                seal.reject(NSError(domain: "User is not signed in", code: 0, userInfo: nil))
            }
        }
    }
    
}
