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
    
    func upload(picture: [String: Any], place: Place) {
        
        if delegate == nil {
            return
        }
        
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
        
        guard place.location != nil else {
            fatalError("location Object expected for uploading photo")
        }
        
        guard place.name != nil else {
            fatalError("place.name attribute expected for uploading photo")
        }
        
        guard let seasonId = picture["season"] as? Int else {
            fatalError("season is missing")
        }
        
        guard let timeId = picture["time"] as? Int else {
            fatalError("time is missing")
        }
        
        guard let dateTaken = picture["date_taken"] as? Int64 else {
            fatalError("date_taken is missing")
        }
        
        Api.uploadImage(data: data, imageName: imageName, place: place, seasonId: seasonId, timeId: timeId, dateTaken: dateTaken, progressHandler: progressHandler).done {
            image in
            self.delegate?.didUpload(image: image)
            }.catch {
                error in
                let nsError = error as NSError
                self.delegate?.onError(error: nsError)
        }
    }
    
    func cancel() {
        NotificationCenter.default.post(name: .CancelUploading, object: self)
        delegate?.cancelledUpload()
    }
}
