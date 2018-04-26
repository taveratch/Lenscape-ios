//
//  Owner.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 2/4/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import Foundation

struct Owner: Codable {
    var name: String!
    var profilePictureLink: String!
    var email: String!
    var id: Int!
    
    init(item: Any) {
        guard let owner = item as? [String: Any] else {
            fatalError("owner item is not kid of [String: String]")
        }
        
        name = "\(owner["firstname"] as! String) \(owner["lastname"] as! String)"
        email = owner["email"] as! String
        profilePictureLink = owner["picture"] as! String
        id = owner["id"] as! Int
    }
}
