//
//  MyPlacesViewController.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 26/4/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit
import Hero

class MyPlacesViewController: UIViewController {

    @IBOutlet weak var navigationBar: NavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGestures()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc private func dismissView() {
        Hero.shared.defaultAnimation = .push(direction: .right)
        dismiss(animated: true)
    }
    
    private func setupGestures() {
        addTapGesture(for: navigationBar.backButton, with: #selector(dismissView))
    }

}
