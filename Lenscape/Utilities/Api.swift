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
    static let UPLOAD_HOST = "https://api.imgur.com/3/image"
    
    // Imgur
    static private let ACCESS_TOKEN = "c792d71fe59ca43a8a4083ce0b0db1b1817ffdb7"
    static private let USERNAME = "lenscapeme"
    
    // MARK: - Authentication
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
    
    // MARK: Sign In
    static func signIn(email: String, password: String) -> Promise<[String: Any]> {
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
    
    static func signInFacebook(token: String) -> Promise<[String: Any]> {
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
    
    // MARK: Sign Up
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
    
    // MARK: - Images
    static func uploadImage(data: Data, progressHandler: ((Int64, Int64) -> Void)? = nil) -> Promise<[String: Any]> {
        let headers : [String: String] = [
            "Authorization": "Bearer \(ACCESS_TOKEN)",
            "Content-Type": "multipart/form-data"
        ]
        
        //TODO: Change this, this is Around me album's id
        return Promise { seal in
            ApiManager.upload(url: UPLOAD_HOST, headers: headers,
                              multipartFormData: { multipartFormData in
                                multipartFormData.append(data, withName: "image", mimeType: "image/jpeg")
                                multipartFormData.append("3Qg3O".data(using: String.Encoding.ascii)!, withName: "album")
            }, progressHandler: progressHandler
                ).done {
                    response in
                    seal.fulfill(response)
                }.catch { error in
                    seal.reject(error)
            }
        }
    }
    
    static func fetchExploreImages(page: Int = 0) -> Promise<[Image]>{
        let headers : [String: String] = [
            "Authorization": "Bearer \(ACCESS_TOKEN)",
            "Content-Type": "multipart/form-data"
        ]
        
        let url = "https://api.imgur.com/3/album/3Qg3O/images"
        
        return Promise {
            seal in
            ApiManager.fetch(url: "\(url)/\(page)", headers: headers, method: "GET").done {
                response in
                let data = response!["data"] as! [Any]
                let images = data
                    .map { Image(item: $0) }
                    .sorted { $0.datetime! > $1.datetime! }
                seal.fulfill(images)
                }.catch {
                    error in
                    seal.reject(error)
                    print(error)
            }
        }
    }
    
    static func getExploreImageCount() -> Promise<Int> {
        let headers : [String: String] = [
            "Authorization": "Bearer \(ACCESS_TOKEN)"
        ]
        
        let url = "https://api.imgur.com/3/album/3Qg3O"
        
        return Promise {
            seal in
            ApiManager.fetch(url: url, headers: headers, method: "GET").done {
                response in
                let count: Int = response!.valueForKeyPath(keyPath: "data.images_count")!
                seal.fulfill(count)
                }.catch {
                    error in
                    seal.reject(error)
            }
        }
    }
    
    static func fetchTrendImages(page: Int = 0) -> Promise<[Image]>{
        let headers : [String: String] = [
            "Authorization": "Bearer \(ACCESS_TOKEN)",
            "Content-Type": "multipart/form-data"
        ]
        
        let url = "https://api.imgur.com/3/album/eG5vv/images"
        
        return Promise {
            seal in
            ApiManager.fetch(url: "\(url)/\(page)", headers: headers, method: "GET").done {
                response in
                let data = response!["data"] as! [Any]
                let images = data
                    .map { Image(item: $0) }
                    .sorted { $0.datetime! > $1.datetime! }
                seal.fulfill(images)
                }.catch {
                    error in
                    seal.reject(error)
                    print(error)
            }
        }
    }
    
    static func getTrendImageCount() -> Promise<Int> {
        let headers : [String: String] = [
            "Authorization": "Bearer \(ACCESS_TOKEN)"
        ]
        
        let url = "https://api.imgur.com/3/album/eG5vv"
        
        return Promise {
            seal in
            ApiManager.fetch(url: url, headers: headers, method: "GET").done {
                response in
                let count: Int = response!.valueForKeyPath(keyPath: "data.images_count")!
                seal.fulfill(count)
                }.catch {
                    error in
                    seal.reject(error)
            }
        }
    }
    
    static func fetchUserImages(page: Int = 0) -> Promise<[Image]> {
        let headers : [String: String] = [
            "Authorization": "Bearer \(ACCESS_TOKEN)",
            "Content-Type": "multipart/form-data"
        ]
        
        let url = "https://api.imgur.com/3/album/eG5vv/images"
        
        return Promise {
            seal in
            ApiManager.fetch(url: "\(url)/\(page)", headers: headers, method: "GET").done {
                response in
                let data = response!["data"] as! [Any]
                let images = data
                    .map { Image(item: $0) }
                    .sorted { $0.datetime! > $1.datetime! }
                seal.fulfill(images)
                }.catch {
                    error in
                    seal.reject(error)
                    print(error)
            }
        }
    }
}
