//
//  TextField.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 5/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit

class TextField: UITextField {
    
    var bottomBorder = UIView()
    
    override func awakeFromNib() {
        
        // Setup Bottom-Border
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        bottomBorder = UIView.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        bottomBorder.backgroundColor = UIColor(cgColor: #colorLiteral(red: 0.9254901961, green: 0.9254901961, blue: 0.9254901961, alpha: 1))
        bottomBorder.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(bottomBorder)
        
        bottomBorder.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        bottomBorder.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        bottomBorder.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        bottomBorder.heightAnchor.constraint(equalToConstant: 1).isActive = true // Set Border-Strength
        
    }
    
    @IBInspectable var hasError = false {
        didSet {
            if hasError {
                bottomBorder.backgroundColor = #colorLiteral(red: 0.8470588235, green: 0, blue: 0.1529411765, alpha: 1)
                setRightViewIcon(icon: UIImage(named: "Invalid")!)
            } else {
                bottomBorder.backgroundColor = UIColor(cgColor: #colorLiteral(red: 0.9254901961, green: 0.9254901961, blue: 0.9254901961, alpha: 1))
            }
        }
    }
    
    @IBInspectable var isValidated = false {
        didSet {
            if isValidated {
                bottomBorder.backgroundColor = UIColor(cgColor: #colorLiteral(red: 0.4117647059, green: 0.9411764706, blue: 0.6823529412, alpha: 1))
                setRightViewIcon(icon: UIImage(named: "Verified")!)
            } else {
                bottomBorder.backgroundColor = UIColor(cgColor: #colorLiteral(red: 0.9254901961, green: 0.9254901961, blue: 0.9254901961, alpha: 1))
            }
        }
    }
}

