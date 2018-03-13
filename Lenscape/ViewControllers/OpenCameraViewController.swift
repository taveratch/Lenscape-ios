//
//  CameraPostingViewController.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 12/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit

class OpenCameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewDidLoad")
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        openCamera()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Functions
    private func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }else {
            print("No camera source type")
        }
    }
    
    private func closeMe() {
        let mainTabBarViewController = self.tabBarController as? MainTabBarController
        mainTabBarViewController?.selectedIndex = (mainTabBarViewController?.currentSelectedIndex)!
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        closeMe()
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        showPhotoPostViewController(image: image)
        dismiss(animated: true, completion: nil)
    }
    
    private func showPhotoPostViewController(image: UIImage?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: Identifier.PhotoPostViewController.rawValue) as? PhotoPostViewController else {
            fatalError("identifier: \(Identifier.PhotoPostViewController.rawValue) is not type of PhotoPostViewController")
        }
        vc.image = image
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    @IBAction func unwindToCamera(sender: UIStoryboardSegue) {
        closeMe()
        dismiss(animated: false, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare")
    }
    

}
