//
//  ApiManager.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 4/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit
import Alamofire
import PromiseKit

class ApiManager {
    
    static func fetch(url: String, headers: [String: String]? = nil, body: [String: Any]? = nil, method: String, encoding: ParameterEncoding? = JSONEncoding.default) -> Promise<[String: Any]?> {
        var httpMethod : HTTPMethod {
            switch method {
            case "GET":
                return HTTPMethod.get
            case "POST":
                return HTTPMethod.post
            case "DELETE":
                return HTTPMethod.delete
            case "PUT":
                return HTTPMethod.put
            default:
                return HTTPMethod.get
            }
        }
        return Promise { seal in
            Alamofire.request(url, method: httpMethod, parameters: body, encoding: encoding!, headers: headers)
                .validate(statusCode: 200...500)
                .responseJSON {
                    response in
                    let value = response.result.value as? [String: Any]
                    let statusCode = response.response?.statusCode
                    if statusCode == 200, value != nil {
                        seal.fulfill(value)
                    } else {
                        seal.reject(NSError(domain: "Error", code: statusCode ?? 500, userInfo: value))
                    }
                }
            }
    }
    
    static func upload(url: String, headers: HTTPHeaders? = nil, multipartFormData: @escaping (MultipartFormData) -> Void, body: [String:String]? = nil, progressHandler: ((Int64, Int64) -> Void)?) -> Promise<[String: Any]> {
        return Promise { seal in
            Alamofire.upload(multipartFormData: multipartFormData, usingThreshold: 1,
                to: url, method: HTTPMethod.post, headers: headers, encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .success(let upload, _, _):
                        print("uploading...")
                        upload.uploadProgress {
                            progress in
                            if progressHandler != nil {
                                progressHandler!(progress.completedUnitCount, progress.totalUnitCount)
                            }
                        }
                        upload.responseString {
                            response in
                            print(response)
                        }
                        upload.responseJSON { response in
                            print("uploaded")
                            guard let value = response.result.value as? [String: Any] else {
                                seal.fulfill([:])
                                return
                            }
                            seal.fulfill(value)
                        }
                    case .failure(let encodingError):
                        print("error")
                        seal.reject(encodingError)
                        print(encodingError)
                    }
            })
        }
    }
}
