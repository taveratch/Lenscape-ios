//
//  MainTabBarController.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 9/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    var currentSelectedIndex: Int = 0
    var sb: UIStoryboard?
    var cameraModal: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        sb = UIStoryboard(name: "Main", bundle: nil)
        cameraModal = sb?.instantiateViewController(withIdentifier: Identifier.OpenCameraViewControllerModal.rawValue)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let identifier = viewController.restorationIdentifier ?? ""
        if identifier == Identifier.OpenCameraViewController.rawValue {
            present(cameraModal!, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        //If open camera then SelectedIndex should not be changed
        let identifier = viewController.restorationIdentifier ?? ""
        if identifier != Identifier.OpenCameraViewController.rawValue {
            currentSelectedIndex = tabBarController.selectedIndex
        }
    }

}
