//
//  UIView.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 29/4/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import Foundation

extension UIView {
    func hideWithAnimation(isHidden: Bool, duration: Double = 0.3) {
        UIView.animate(withDuration: duration, animations: {
            self.isHidden = isHidden
            self.superview?.layoutIfNeeded()
        })
    }
}
