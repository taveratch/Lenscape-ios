//
//  Api.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 4/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import Foundation
import PromiseKit

class Api {
    
    static let HOST = "https://api.lenscape.me"
    
    static private func getUserFromAuthResponse(response: [String: Any]) -> [String: Any] {
        guard var user: [String: Any] = response.valueForKeyPath(keyPath: "user")! else {
            fatalError("No key `user` found in auth response")
        }
        guard let token: String = response.valueForKeyPath(keyPath: "token")! else {
            fatalError("No key `token` found in auth response")
        }
        user["token"] = token
        return user
    }
    
    static func signin(email: String, password: String) -> Promise<[String: Any]> {
        let body = [
            "email": email,
            "password": password
        ]
        return Promise { seal in
            firstly {
                ApiManager.fetch(url: "\(HOST)/login/local", header: nil, body: body, method: "POST")
                }.done { response in
                    let user = getUserFromAuthResponse(response: response!)
                    if UserController.saveUser(user: user) {
                        seal.fulfill(user)
                    }else {
                        seal.reject(NSError(domain: "Cannot save user to UserDefault", code: 0, userInfo: nil))
                    }
                }.catch { error in
                    seal.reject(error)
            }
        }
    }
    
    static func signinFacebook(token: String) -> Promise<[String: Any]> {
        let body = [
            "access_token": token
        ]
        return Promise {
            seal in
            ApiManager.fetch(url: "\(HOST)/login/facebook", header: nil, body: body, method: "POST")
                .done {
                    response in
                    let user = getUserFromAuthResponse(response: response!)
                    if UserController.saveUser(user: user) {
                        seal.fulfill(user)
                    }else {
                        seal.reject(NSError(domain: "Cannot save user to UserDefault", code: 0, userInfo: nil))
                    }
                }.catch{ error in
                    seal.reject(error)
            }
        }
    }
}
