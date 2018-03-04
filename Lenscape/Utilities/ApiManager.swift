//
//  ApiManager.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 4/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import Foundation
import Alamofire

class ApiManager {
    func fetch(url:String, header: [String: String]?, body: [String: Any]?, method: String, completionHandler: @escaping (_ response: [String: Any]?) -> Void) {
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
        Alamofire.request(url, method: httpMethod, parameters: body, encoding: JSONEncoding.default, headers: header).responseJSON {
            response in
            completionHandler(response.result.value as? [String : Any])
        }
    }
}
