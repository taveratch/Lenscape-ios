//
//  PhotoUploadingDelegate.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 17/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import Foundation

protocol PhotoUploadingDelegate {
    func didUpload()
    func uploading(completedUnit: Double, totalUnit: Double)
    func willUpload()
}
