//
//  PhotoPostViewController.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 12/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit
import Alamofire

class PhotoPostViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var informationCard: PhotoUploadInformationCard!
    
    var image: UIImage?
    let photoUploader = PhotoUploader()
    private let dataProvider = GoogleDataProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboard()
        fetchNearbyPlaces()
    }
    
    // MARK: Setup for moving view to show textfield when keyboard is presented
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
    }
    
    // https://stackoverflow.com/questions/5143873/dismissing-the-keyboard-in-a-uiscrollview?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
    private func setupKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func hideKeyboard() {
        informationCard.caption.resignFirstResponder()
    }
    
    private func setupUI() {
        imageView.image = image
        informationCard.caption.delegate = self
    }
    
    // Hide status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Cancel", message: "Cancel sharing photo?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
            action in
            self.performSegue(withIdentifier: "unwindToCameraAndDisiss", sender: self)
        }))
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func closeMe() {
        let mainTabBarViewController = self.tabBarController as? MainTabBarController
        mainTabBarViewController?.selectedIndex = (mainTabBarViewController?.currentSelectedIndex)!
        dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func upload(_ sender: UIBarButtonItem) {
        if let data = UIImageJPEGRepresentation(image!,1) {
            let imageInfo: [String: Any] = [
                "picture": data,
                "image_name": informationCard.caption.text ?? "CPE Building",
                "location_name": "Kasetsart University"
            ]
            // the data can be passed to ExploreViewController via UserDefaults
            UserDefaults.standard.set(imageInfo, forKey: "uploadPhotoInfo")
            self.performSegue(withIdentifier: "unwindToCameraAndDisiss", sender: self)
        }
    }
    
    private func fetchNearbyPlaces() {
        print("fetchNearbyPlaces")
        let location = LocationManager.getInstance().currentLocation
        dataProvider.fetchPlacesNearCoordinate(CLLocationCoordinate2D(latitude: (location?.latitude)!, longitude: (location?.longitude)!), radius: 1000, types: ["food"]) {
            places in
            print(places)
        }
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height + 50, 0.0)
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
            var aRect: CGRect = self.view.frame
            aRect.size.height -= keyboardSize.height
            
            if !aRect.contains(informationCard.caption.frame.origin) {
                self.scrollView.scrollRectToVisible(informationCard.caption.frame, animated: true)
            }
        }
    }
    
//    @IBAction func showFullImage(_ sender: UITapGestureRecognizer) {
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: Identifier.FullImageViewController.rawValue) as! FullImageViewController
//        vc.image = image
//        vc.placeHolderImage = uiImage
//        vc.hero.modalAnimationType = .auto
//        present(vc, animated: true)
//    }
    
}

extension PhotoPostViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
}
