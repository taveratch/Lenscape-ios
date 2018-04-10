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
    
    func upload(picture: [String: Any], location: Location? = nil) {
        isUploading = true
        self.delegate?.willUpload()
        let progressHandler = {
            (completedUnit: Int64, totalUnit: Int64) -> Void in
            self.delegate?.uploading(completedUnit: Double(completedUnit), totalUnit: Double(totalUnit))
        }
        guard let data = picture["picture"] as? Data else {
            fatalError("picture attribute expected for uploading photo")
        }
        
        guard let imageName = picture["image_name"] as? String else {
            fatalError("image_name attribute expected for uploading photo")
        }
        
        guard location != nil else {
            fatalError("location Object expected for uploading photo")
        }
        
        guard let locationName = picture["location_name"] as? String else {
            fatalError("location_name attribute expected for uploading photo")
        }
        
        let gplaceID = picture["gplace_id"] as? String
        
        let _ = Api.uploadImage(data: data, location: location, imageName: imageName, locationName: locationName, gplaceID: gplaceID, progressHandler: progressHandler).done {
            response in
            self.delegate?.didUpload()
        }
    }
    
    func cancel() {
        NotificationCenter.default.post(name: .CancelUploading, object: self)
        delegate?.cancelledUpload()
    }
}
