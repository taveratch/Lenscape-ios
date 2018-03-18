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
    
    //    static let HOST = "https://api.lenscape.me"
    static let HOST = "https://demo9833354.mockable.io"
    static let UPLOAD_HOST = "https://api.imgur.com/3/image"
    
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
                ApiManager.fetch(url: "\(HOST)/login/local", body: body, method: "POST")
                }.done { response in
                    let user = getUserFromAuthResponse(response: response!)
                    seal.fulfill(user)
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
            ApiManager.fetch(url: "\(HOST)/login/facebook", body: body, method: "POST")
                .done {
                    response in
                    let user = getUserFromAuthResponse(response: response!)
                    seal.fulfill(user)
                }.catch{ error in
                    seal.reject(error)
            }
        }
    }
    
    static func signUp(picture: UIImage? = nil, firstName: String, lastName: String, email: String, password: String) -> Promise<[String: Any]> {
        let body = [
            "firstname": firstName,
            "lastname": lastName,
            "email": email,
            "password": password
        ]
        return Promise { seal in
            firstly {
                ApiManager.fetch(url: "\(HOST)/register", body: body, method: "POST")
                }.done { response in
                    let user = getUserFromAuthResponse(response: response!)
                    seal.fulfill(user)
                }.catch { error in
                    seal.reject(error)
            }
        }
    }
    
    static func uploadImage(data: Data, progressHandler: ((Int64, Int64) -> Void)? = nil) -> Promise<[String: Any]> {
        let headers : [String: String] = [
            "Authorization": "Bearer 5324dfca0c9089125f1497f5eb2473ceaaac2da8",
            "Content-Type": "multipart/form-data"
        ]
        return Promise { seal in
            ApiManager.upload(url: UPLOAD_HOST, headers: headers,
                              multipartFormData: { multipartFormData in
                                multipartFormData.append(data, withName: "image", mimeType: "image/jpeg")
            }, progressHandler: progressHandler
                ).done {
                    response in
                    seal.fulfill(response)
                }.catch { error in
                    seal.reject(error)
            }
        }
    }
}
