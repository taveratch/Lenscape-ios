//
//  UploadController.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 16/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import Foundation

class UploadController {
    static var isUploading: Bool = false
    static var observers: [() -> Void] = []
    static var completedUnit: Int64 = 1 {
        didSet {
            isUploading = completedUnit != totalUnit
            notifyAll()
        }
    }
    static var totalUnit: Int64 = 1 {
        didSet {
            isUploading = totalUnit != completedUnit
            notifyAll()
        }
    }
    static var percentage: Double {
        let percent = (Double(completedUnit) / Double(totalUnit)) * 100.0
        if(percent == 100.0) {
            isUploading = false
        }
        return percent
    }
    
    static func notifyAll() {
        for observer in observers {
            observer()
        }
    }
    static func addObserver(closure: @escaping () -> Void) {
        observers.append(closure)
    }
    static func clearObservers() {
        observers.removeAll()
    }
}
