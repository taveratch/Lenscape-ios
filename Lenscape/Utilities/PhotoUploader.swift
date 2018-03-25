//
//  Uploader.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 17/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import Foundation

class PhotoUploader {
    var delegate: PhotoUploadingDelegate?
    var isUploading: Bool = false
    
    func upload(data: Data, location: Location? = nil) {
        isUploading = true
        self.delegate?.willUpload()
        let progressHandler = {
            (completedUnit: Int64, totalUnit: Int64) -> Void in
            self.delegate?.uploading(completedUnit: Double(completedUnit), totalUnit: Double(totalUnit))
        }
        Api.uploadImage(data: data, location: location, progressHandler: progressHandler).done {
            response in
            self.delegate?.didUpload()
        }
    }
}
