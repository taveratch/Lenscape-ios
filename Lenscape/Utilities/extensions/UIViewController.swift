//
//  UIViewController.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 29/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    class func displaySpinner(onView : UIView) -> UIView {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        return spinnerView
    }
    
    class func removeSpinner(spinner :UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
    
    func addTapGesture(for view: UIView, with action: Selector?, param: Any? = nil) {
        let tap = UITapGestureRecognizerWithParam(target: self, action: action)
        tap.param = param
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
    }
    
    func showAlertDialog(title: String? = nil, message: String) {
        AlertController.showAlert(viewController: self, title: title, message: message)
    }
}
