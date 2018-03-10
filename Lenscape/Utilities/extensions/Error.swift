//
//  Error.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 10/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import Foundation

extension Error {
    var code: Int { return (self as NSError).code }
    var domain: String { return (self as NSError).domain }
}
