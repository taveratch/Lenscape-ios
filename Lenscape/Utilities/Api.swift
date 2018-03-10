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
    
    let HOST = "http://api.lenscape.me"
    let apiManager = ApiManager()
    
    func signin(email: String, password: String) -> Promise<[String: Any]> {
        let body = [
            "email": email,
            "password": password
        ]
        return Promise { seal in
            firstly {
                apiManager.fetch(url: "\(HOST)/login/local", header: nil, body: body, method: "POST")
                }.done { response in
                    var user: [String: Any] = response!.valueForKeyPath(keyPath: "user")!
                    let token: String = response!.valueForKeyPath(keyPath: "token")!
                    user["token"] = token
                    if UserController.saveUser(user: user) {
                        seal.fulfill(user)
                    }
                }.catch { error in
                    seal.reject(error)
            }
        }
    }
}
