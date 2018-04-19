//
//  ComponentUtil.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 19/4/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit

class ComponentUtil {
    static func fade(of view: UIView, hidden: Bool) {
        if hidden {
            UIView.animate(withDuration: 0.2, animations: {
                view.alpha = 0
            }) {
                finished in
                view.isHidden = true
            }
        }else {
            view.isHidden = false
            UIView.animate(withDuration: 0.2, animations: {
                view.alpha = 1
            })
        }
    }
    
    static func addTapGesture(parentViewController: UIViewController, for view: UIView, with action: Selector?) {
        let tap = UITapGestureRecognizer(target: parentViewController, action: action)
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
    }
}
