//
//  CustomTabBar.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 20/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit

@IBDesignable
class CustomTabBar : UITabBar {
    @IBInspectable var moreHeight: CGFloat = 0.0
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = sizeThatFits.height + moreHeight
        return sizeThatFits
    }
}
