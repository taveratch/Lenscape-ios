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
    @IBOutlet weak var shareButton: ShadowView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backButton: UIImageView!
    @IBOutlet weak var informationCard: PhotoUploadInformationCard!
    
    var image: UIImage?
    let photoUploader = PhotoUploader()
    private let dataProvider = GoogleDataProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboard()
        fetchNearbyPlaces()
        setupShareButton()
        setupBackButton()
        
        //https://github.com/lkzhao/Hero/issues/187
        informationCard.hero.modifiers = [.duration(0.4), .translate(y: informationCard.bounds.height*2), .beginWith([.zPosition(10)]), .useGlobalCoordinateSpace]
        
        // Shared hero's id with PhotoPreviewViewController
        shareButton.hero.id = "Next"
    }
    
    // MARK: Setup for moving view to show textfield when keyboard is presented
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        runThisAfter(second: 0.5) {
            self.informationCard.caption.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
    }
    
    
    private func runThisAfter(second: Double, execute: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + (second), execute: execute)
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
    
    @objc func back() {
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
    
    /*
    * Are all required information filled or not.
        1. Caption
        2. Place
    */
    private func isValid() -> Bool {
        return !informationCard.caption.text!.isEmpty
    }
    
    private func showMessageDialog(message: String) {
        let alert = UIAlertController(title: "Message", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc func upload() {
        if !isValid() {
            showMessageDialog(message: "Please specify image's caption and place where it has been shot")
            return
        }
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
    
//    @objc private func back() {
//        dismiss(animated: true)
//    }
    
    private func setupShareButton() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(upload))
        shareButton.addGestureRecognizer(tap)
        shareButton.isUserInteractionEnabled = true
    }
    
    private func setupBackButton() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(back))
        backButton.addGestureRecognizer(tap)
        backButton.isUserInteractionEnabled = true
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
