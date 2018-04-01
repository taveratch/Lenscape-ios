//
//  Api.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 4/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import Foundation
import Alamofire
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
    static func uploadImage(data: Data, location: Location? = nil, imageName: String? = "IUP Building", locationName: String? = "Kasetsart University",progressHandler: ((Int64, Int64) -> Void)? = nil) -> Promise<[String: Any]> {
        
        let headers : HTTPHeaders = [
            "Authorization": "Bearer \(UserController.getToken())",
            "Content-Type": "multipart/form-data"
        ]
        
        return Promise { seal in
            ApiManager.upload(url: "\(HOST)/photo", headers: headers,
                              multipartFormData: { multipartFormData in
                                multipartFormData.append(data, withName:"picture", fileName: "Photo.jpeg", mimeType: "image/jpeg")
                                multipartFormData.append(imageName!.data(using: String.Encoding.utf8)!, withName: "picture_name")
                                multipartFormData.append(locationName!.data(using: String.Encoding.utf8)!, withName: "location_name")
                                multipartFormData.append("\(location!.latitude),\(location!.longitude)".data(using: String.Encoding.utf8)!, withName: "latlong")
            }, progressHandler: progressHandler
                ).done {
                    response in
                    print(response)
                    seal.fulfill(response)
                }.catch { error in
                    seal.reject(error)
            }
        }
    }
    
    
    
    static func fetchExploreImages(page: Int = 1, location: Location, month: Int = 0) -> Promise<[String: Any]>{
        
        let headers : [String: String] = [
            "Authorization": "Bearer \(UserController.getToken())"
        ]
        
        let parameters: [String: String] = [
            "latlong": "\(location.latitude),\(location.longitude)",
            "month": String(month),
            "page": String(page)
        ]
        
        let url = "\(HOST)/aroundme/photos"
        return Promise {
            seal in
            ApiManager.fetch(url: url, headers: headers, body: parameters, method: "GET", encoding: URLEncoding(destination: .queryString)).done {
                response in
                let data = response!["data"] as! [Any]
                var images = data
                    .map { Image(item: $0) }
                
                //TODO: Removed this and sort by timestamp
                images = images.reversed()
                
                let fulfill: [String: Any] = [
                    "images" : images,
                    "pagination": Pagination(pagination: response!["pagination"] as? [String: Any])
                ]
                
                seal.fulfill(fulfill)
                }.catch {
                    error in
                    print(error.domain)
                    seal.reject(error)
                    print(error)
            }
        }
    }
    
    static func fetchTrendImages(page: Int = 0) -> Promise<[String: Any]>{
        
        let headers : [String: String] = [
            "Authorization": "Bearer \(UserController.getToken())"
        ]
        
        //TODO: remove this after use trend api
        let location = LocationManager.getInstance().getCurrentLocation()!
        
        //TODO: remove latlong and month
        let parameters: [String: String] = [
            "latlong": "\(location.latitude),\(location.longitude)",
            "month": "0",
            "page": String(page)
        ]
        
        //TODO: Change to trend api
        let url = "\(HOST)/aroundme/photos"
        
        return Promise {
            seal in
            ApiManager.fetch(url: url, headers: headers, body: parameters, method: "GET", encoding: URLEncoding(destination: .queryString)).done {
                response in
                let data = response!["data"] as! [Any]
                var images = data
                    .map { Image(item: $0) }
                
                //TODO: Remove this and sort by timestamp
                images = images.reversed()
                
                let fulfill: [String: Any] = [
                    "images" : images,
                    "pagination": Pagination(pagination: response!["pagination"] as? [String: Any])
                ]
                
                seal.fulfill(fulfill)
                }.catch {
                    error in
                    print(error.domain)
                    seal.reject(error)
                    print(error)
            }
        }
    }
    
    static func fetchUserImages(page: Int = 0) -> Promise<[String: Any]> {
        let headers : [String: String] = [
            "Authorization": "Bearer \(UserController.getToken())"
        ]
        
        //TODO: remove this after use trend api
        let location = LocationManager.getInstance().getCurrentLocation()!
        
        //TODO: remove latlong and month
        let parameters: [String: String] = [
            "latlong": "\(location.latitude),\(location.longitude)",
            "month": "0",
            "page": String(page)
        ]
        
        //TODO: Change to trend api
        let url = "\(HOST)/aroundme/photos"
        
        return Promise {
            seal in
            ApiManager.fetch(url: url, headers: headers, body: parameters, method: "GET", encoding: URLEncoding(destination: .queryString)).done {
                response in
                let data = response!["data"] as! [Any]
                var images = data
                    .map { Image(item: $0) }
                
                //TODO: Remove this and sort by timestamp
                images = images.reversed()
                
                let fulfill: [String: Any] = [
                    "images" : images,
                    "pagination": Pagination(pagination: response!["pagination"] as? [String: Any])
                ]
                
                seal.fulfill(fulfill)
                }.catch {
                    error in
                    print(error.domain)
                    seal.reject(error)
                    print(error)
            }
        }
    }
}
