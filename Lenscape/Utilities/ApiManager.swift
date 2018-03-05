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
    
    func fetch(url:String, header: [String: String]?, body: [String: Any]?, method: String) -> Promise<[String: Any]?>{
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
            Alamofire.request(url, method: httpMethod, parameters: body, encoding: JSONEncoding.default, headers: header).responseJSON {
                response in
                switch response.result {
                case .success:
                    seal.fulfill(response.result.value as? [String: Any])
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
}
