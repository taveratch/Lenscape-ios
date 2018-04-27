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
    
    static let HOST = "https://dev.api.lenscape.me"
    
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
    static func signUp(picture: UIImage? = nil, firstName: String,
                       lastName: String, email: String, password: String) -> Promise<[String: Any]> {

        return Promise { seal in
            ApiManager.upload(
                url: "\(HOST)/register",
                headers: ["Content-Type": "multipart/form-data"],
                multipartFormData: { data in
                    if let picture = picture, let imageData = UIImageJPEGRepresentation(picture, 0.5)  {
                        data.append(
                            imageData,
                            withName:"picture",
                            fileName: "Photo.jpeg",
                            mimeType: "image/jpeg"
                        )
                    }
                    data.append(firstName.data(using: .utf8)!, withName: "firstname")
                    data.append(lastName.data(using: .utf8)!, withName: "lastname")
                    data.append(email.data(using: .utf8)!, withName: "email")
                    data.append(password.data(using: .utf8)!, withName: "password")
            }
                ).done { response in
                    let user = getUserFromAuthResponse(response: response)
                    seal.fulfill(user)
                }.catch { error in
                    seal.reject(error)
            }
        }
    }
    
    // MARK: - Images
    static func uploadImage(data: Data, imageName: String, place: Place, seasonId: Int, timeId: Int, dateTaken: Int64,
                            progressHandler: ((Int64, Int64) -> Void)? = nil) -> Promise<[String: Any]> {
        
        let headers : HTTPHeaders = [
            "Authorization": "Bearer \(UserController.getToken())",
            "Content-Type": "multipart/form-data"
        ]
        
        let latlong = "\(place.location.latitude),\(place.location.longitude)"
        
        print("\n-- Api.uploadImage --")
        print("picture: \(data)")
        print("image_name: \(imageName)")
        print("location_name: \(place.name)")
        print("latlong: \(latlong)")
        print("place_id: \(place.placeID)")
        print("place_type: \(place.type)")
        print("--------------------\n")
        
        return Promise { seal in
            ApiManager.upload(
                url: "\(HOST)/photo",
                headers: headers,
                multipartFormData: { multipartFormData in
                    multipartFormData.append(data, withName:"picture", fileName: "Photo.jpeg", mimeType: "image/jpeg")
                    multipartFormData.append(imageName.data(using: .utf8)!, withName: "image_name")
                    multipartFormData.append(place.name.data(using: .utf8)!, withName: "location_name")
                    multipartFormData.append(latlong.data(using: .utf8)!, withName: "latlong")
                    multipartFormData.append(place.placeID.data(using: .utf8)!, withName: "place_id")
                    multipartFormData.append(place.type.data(using: .utf8)!, withName: "place_type")
                    multipartFormData.append(String(seasonId).data(using: .utf8)!, withName: "season")
                    multipartFormData.append(String(timeId).data(using: .utf8)!, withName: "time_taken")
                    multipartFormData.append(String(dateTaken).data(using: .utf8)!, withName: "date_taken")
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
    
    
    
    static func fetchExploreImages(page: Int = 1, location: Location, month: Int = 0, size: Int = 25) -> Promise<[String: Any]>{
        
        let headers : [String: String] = [
            "Authorization": "Bearer \(UserController.getToken())"
        ]
        
        var userLocation = LocationManager.getInstance().getCurrentLocation()
        if userLocation == nil {
            userLocation = location
        }
        
        let parameters: [String: String] = [
            "target_latlong": "\(location.latitude),\(location.longitude)",
            "user_latlong": "\(userLocation!.latitude),\(userLocation!.longitude)",
            "month": String(month),
            "page": String(page),
            "size": String(size)
        ]
        
        let url = "\(HOST)/photos"
        return Promise {
            seal in
            ApiManager.fetch(url: url, headers: headers, body: parameters, method: "GET", encoding: URLEncoding(destination: .queryString)).done {
                response in
                let data = response!["data"] as! [Any]
                let images = data
                    .map { Image(item: $0) }
                
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
    
    static func fetchTrendImages(page: Int = 1) -> Promise<[String: Any]>{
        
        let headers : [String: String] = [
            "Authorization": "Bearer \(UserController.getToken())"
        ]
        
        let parameters: [String: String] = [
            "page": String(page)
        ]
        
        let url = "\(HOST)/trend"
        
        return Promise {
            seal in
            ApiManager.fetch(url: url, headers: headers, body: parameters, method: "GET", encoding: URLEncoding(destination: .queryString)).done {
                response in
                let data = response!["data"] as! [Any]
                var images = data
                    .map { Image(item: $0) }
                
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
    
    static func likeImage(imageId: Int, liked: Bool) -> Promise<Image> {
        let headers : [String: String] = [
            "Authorization": "Bearer \(UserController.getToken())"
        ]
        
        let url = "\(HOST)/photo/\(imageId)/like"
        let method = liked ? "POST" : "DELETE"
        
        return Promise {
            seal in
            ApiManager.fetch(url: url, headers: headers, body: nil, method: method).done {
                response in
                let image = Image(item: response)
                seal.fulfill(image)
                }.catch {
                    error in
                    print(error)
                    seal.reject(error)
            }
        }
    }
    
    static func getImages(placeId: String, page: Int = 1, isOwner: Bool = false) -> Promise<[String: Any]> {
        let headers : [String: String] = [
            "Authorization": "Bearer \(UserController.getToken())"
        ]
        
        let url = "\(HOST)/location/\(placeId)/photos"
        
        let parameters : [String: String] = [
            "page": String(page),
            "is_owner": String(isOwner)
        ]
        
        return Promise {
            seal in
            ApiManager.fetch(url: url, headers: headers, body: parameters, method: "GET", encoding: URLEncoding(destination: .queryString)).done {
                response in
                let data = response!["data"] as! [Any]
                let images = data.map { Image(item: $0) }
                
                seal.fulfill([
                    "pagination": Pagination(pagination: response!["pagination"] as? [String: Any]),
                    "images": images
                ])
                }.catch {
                    error in
                    print(error)
                    seal.reject(error)
            }
        }
    }
    
    static func getPartsOfDay() -> Promise<[PartOfDay]> {
        let headers : [String: String] = [
            "Authorization": "Bearer \(UserController.getToken())"
        ]
        
        let url = "\(HOST)/times"
        
        return Promise {
            seal in
            ApiManager.fetch(url: url, headers: headers, method: "GET").done {
                response in
                let data = response!["data"] as! [Any]
                let partsOfDay = data.map { PartOfDay(item: $0) }
                
                seal.fulfill(partsOfDay)
                }.catch {
                    error in
                    print(error)
                    seal.reject(error)
            }
        }
    }
    
    static func getSeasons() -> Promise<[Season]> {
        let headers : [String: String] = [
            "Authorization": "Bearer \(UserController.getToken())"
        ]
        
        let url = "\(HOST)/seasons"
        
        return Promise {
            seal in
            ApiManager.fetch(url: url, headers: headers, method: "GET").done {
                response in
                let data = response!["data"] as! [Any]
                let seasons = data.map { Season(item: $0) }
                
                seal.fulfill(seasons)
                }.catch {
                    error in
                    print(error)
                    seal.reject(error)
            }
        }
    }
    
    static func searchLocations(currentLocation: Location, searchQuery: String = "") -> Promise<[Place]>{
        let headers : [String: String] = [
            "Authorization": "Bearer \(UserController.getToken())"
        ]
        
        let url = "\(HOST)/aroundme/places"
        
        let parameters = [
            "latlong": currentLocation.getLatlongFormat(),
            "search": searchQuery
        ]
        
        return Promise {
            seal in
            ApiManager.fetch(url: url, headers: headers, body: parameters, method: "GET", encoding: URLEncoding(destination: .queryString)).done {
                response in
                let data = response!["data"] as! [Any]
                let places = data.map{ Place(item: $0) }
                seal.fulfill(places)
                }.catch {
                    error in
                    print(error)
                    seal.reject(error)
            }
        }
    }
    
    static func fetchMeImages(page: Int = 1, size: Int = 25) -> Promise<[String: Any]>{
        
        let headers : [String: String] = [
            "Authorization": "Bearer \(UserController.getToken())"
        ]
        
        let parameters: [String: String] = [
            "page": String(page),
            "size": String(size)
        ]
        
        let url = "\(HOST)/me/photos"
        return Promise {
            seal in
            ApiManager.fetch(url: url, headers: headers, body: parameters, method: "GET", encoding: URLEncoding(destination: .queryString)).done {
                response in
                let data = response!["data"] as! [Any]
                let images = data
                    .map { Image(item: $0) }
                
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
    
    static func fetchMyPlaces() -> Promise<[Place]>{
        let headers : [String: String] = [
            "Authorization": "Bearer \(UserController.getToken())"
        ]
        let url = "\(HOST)/me/locations"
        
        return Promise {
            seal in
            ApiManager.fetch(url: url, headers: headers, method: "GET").done {
                response in
                let data = response!["data"] as! [Any]
                let places = data.map { Place(item: $0) }
                seal.fulfill(places)
                }.catch {
                    error in
                    print(error.domain)
                    seal.reject(error)
                    print(error)
            }
        }
    }
    
    static func deletePhoto(photoId: Int) -> Promise<Image> {
        let headers : [String: String] = [
            "Authorization": "Bearer \(UserController.getToken())"
        ]
        let url = "\(HOST)/photo/\(photoId)"
        
        return Promise {
            seal in
            ApiManager.fetch(url: url, headers: headers, method: "DELETE").done {
                response in
                let image = Image(item: response as Any)
                seal.fulfill(image)
                }.catch {
                    error in
                    print(error)
                    seal.reject(error)
            }
        }
    }
    
    static func viewPhoto(photoId: Int) -> Promise<Image> {
        let headers : [String: String] = [
            "Authorization": "Bearer \(UserController.getToken())"
        ]
        let url = "\(HOST)/photo/\(photoId)/view"
        
        return Promise {
            seal in
            ApiManager.fetch(url: url, headers: headers, method: "POST").done {
                response in
                let image = Image(item: response as Any)
                seal.fulfill(image)
                }.catch {
                    error in
                    print(error)
                    seal.reject(error)
            }
        }
    }
}
