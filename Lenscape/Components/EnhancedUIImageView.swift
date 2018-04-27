//
//  EnhancedUIImage.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 9/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit

@IBDesignable
class EnhancedUIImage: UIImageView {
    
    var isCircular = false
    
    private func initUI() {
        self.clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    @IBInspectable var circular: Bool {
        set {
            self.isCircular = newValue
            if newValue {
                self.layer.masksToBounds = true
                self.layer.cornerRadius = self.frame.height/2
            } else {
                self.layer.masksToBounds = false
                self.layer.cornerRadius = 0
            }
        }
        get {
            return self.isCircular
        }
    }
}

