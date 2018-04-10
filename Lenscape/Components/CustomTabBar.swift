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
    private var middleButton = UIButton()
    
    var heroUITabBarDelegate: HeroUITabBarDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupMiddleButton()
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = sizeThatFits.height + moreHeight
        return sizeThatFits
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        if self.isHidden {
            return super.hitTest(point, with: event)
        }
        
        let from = point
        let to = middleButton.center
        
        return sqrt((from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)) <= 39 ? middleButton : super.hitTest(point, with: event)
    }
    
    // TODO: Fix button shape not being completely round and image appears to be blurry
    func setupMiddleButton() {
        middleButton.frame.size = CGSize(width: 74, height: 74)
        middleButton.layer.cornerRadius = 74/2
        middleButton.setBackgroundImage(UIImage(named: "Camera_gradient_tab_icon"), for: .normal)
        middleButton.layer.masksToBounds = true
        middleButton.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: 0)
        middleButton.addTarget(self, action: #selector(onClick), for: .touchUpInside)
        addSubview(middleButton)
    }
    
    @objc private func onClick() {
        heroUITabBarDelegate?.onHeroButtonClicked()
    }
}
