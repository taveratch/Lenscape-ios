//
//  ShadowView.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 9/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit

@IBDesignable
class ShadowView: UIView {
    func initUI() {
        layer.masksToBounds = false
        layer.cornerRadius = 5
        layer.shadowColor = #colorLiteral(red: 0.8711046614, green: 0.8773157559, blue: 0.8959490395, alpha: 1)
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowOpacity = 0.7
        layer.shadowRadius = 3
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var shadowColor: CGColor {
        set {
            layer.shadowColor = newValue
        }
        get {
            return layer.shadowColor!
        }
    }
    
    @IBInspectable var shadowOffset: CGSize {
        set {
            layer.shadowOffset = newValue
        }
        get {
            return layer.shadowOffset
        }
    }
    
    @IBInspectable var shadowOpacity: Float {
        set {
            layer.shadowOpacity = newValue
        }
        get {
            return layer.shadowOpacity
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat {
        set {
            layer.shadowRadius = newValue
        }
        get {
            return layer.shadowRadius
        }
    }
}
