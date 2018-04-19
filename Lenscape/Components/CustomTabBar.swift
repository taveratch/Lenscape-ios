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

    func setupMiddleButton() {
        let width: CGFloat = 60, height: CGFloat = 60
        middleButton.frame.size = CGSize(width: width, height: height)
        middleButton.setBackgroundImage(UIImage(named: "Camera Gradient Icon No Shadow"), for: .normal)
        middleButton.layer.masksToBounds = false
        middleButton.layer.shadowColor = #colorLiteral(red: 0.9450980392, green: 0.4705882353, blue: 0.3647058824, alpha: 0.67)
        middleButton.layer.shadowRadius = 4
        middleButton.layer.shadowOpacity = 1
        middleButton.layer.shadowOffset = CGSize(width: 0, height: 5)
        middleButton.layer.cornerRadius = width/2
        middleButton.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: 0)
        middleButton.addTarget(self, action: #selector(onClick), for: .touchUpInside)
        addSubview(middleButton)
    }
    
    @objc private func onClick() {
        heroUITabBarDelegate?.onHeroButtonClicked()
    }
}
