//
//  Api.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 4/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import Foundation

class Api {
    
    let HOST = "https://demo9833354.mockable.io"
    let apiManager = ApiManager()
    
    func signin(email: String, password: String, completion: @escaping (_ user: [String: Any]) -> Void) {
        let body = [
            "email": email,
            "password": password
        ]
        
        apiManager.fetch(url: HOST + "/users/signin", header: nil, body: body, method: "POST") {
            response -> Void in
            if response != nil, response!["success"] as! Bool  {
                let user = response!["data"] as! [String: Any]
                if UserController.saveUser(user: user) {
                    completion(user)
                }
            }
        }
    }
}
