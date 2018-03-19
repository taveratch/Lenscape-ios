//
//  Image.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 19/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import Foundation

struct Image {
    var title: String?
    var type: String?
    var id: String?
    var width: Int?
    var height: Int?
    var link: String?
    var thumbnailLink: String?
    init(item: Any) {
        guard let image = item as? [String: Any] else {
            fatalError("\(item) is not instance of dictionary [String: Any]")
        }
        title = image["title"] as? String
        type = image["type"] as? String
        id = image["id"] as? String
        width = image["width"] as? Int
        height = image["height"] as? Int
        link = image["link"] as? String
        let index = link!.index(link!.endIndex, offsetBy: -4)
        thumbnailLink = "\(link![..<index])b\(link![index...])"
    }
}
