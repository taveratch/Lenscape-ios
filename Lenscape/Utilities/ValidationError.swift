//
//  ValidationError.swift
//  Lenscape
//
//  Created by Thongrapee Panyapatiphan on 3/27/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import Foundation

enum ValidationError: Error {
    case required
    case invalidInput(String)
}

