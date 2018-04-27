//
//  AlertController.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 21/4/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import Foundation

class AlertController {
    static func showAlert(viewController: UIViewController, title: String? = "Message", message: String, completeHandler: @escaping () -> Void = {}) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel) {
            action in
            alert.dismiss(animated: true)
            completeHandler()
        })
        viewController.present(alert, animated: true)
    }
}
