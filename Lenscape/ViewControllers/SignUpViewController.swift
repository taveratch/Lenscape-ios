//
//  SignupViewController.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 6/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    
    // MARK: - UI Components
    
    @IBOutlet private var textFields: [TextField]!
    @IBOutlet private weak var profileImageView: EnhancedUIImage!
    @IBOutlet private weak var firstNameTextField: TextField!
    @IBOutlet private weak var lastNameTextField: TextField!
    @IBOutlet private weak var emailTextField: TextField!
    @IBOutlet private weak var passwordTextField: TextField!
    @IBOutlet private weak var confirmPasswordTextField: TextField!
    @IBOutlet private weak var scrollView: UIScrollView!
    var activeField: UITextField?
    private lazy var imagePickerController = UIImagePickerController()
    
    
    // MARK: - Computed properties
    
    private var isPasswordMatched: Bool {
        return confirmPasswordTextField.text == passwordTextField.text
    }
    
    private var isFormCompleted: Bool {
        return textFields.filter { !$0.hasText }.isEmpty
    }
    
    // MARK: - Actions
    
    @IBAction func signUp(_ sender: UIButton) {
        
        guard isFormCompleted else {
            textFields.filter { !$0.hasText }.forEach { $0.hasError = true }
            return
        }
        
        resetForm()
        
        guard isPasswordMatched else {
            confirmPasswordTextField.hasError = true
            return
        }
        
        resetForm()
        
        let firstName = firstNameTextField.text!
        let lastName = lastNameTextField.text!
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        Api.signUp(
            picture: profileImageView.image,
            firstName: firstName,
            lastName: lastName,
            email: email,
            password: password
            ).done {
                user in
                UserController.saveUser(user: user)
                let identifier = Identifier.MainTabBarController.rawValue
                if let viewController = self.storyboard?.instantiateViewController(withIdentifier: identifier) {
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
            }.catch { error in
                let alert = UIAlertController(title: "Message", message: error.domain
                , preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
        }
        
    }
    
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        present(imagePickerController, animated: true)
    }
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textFields.forEach { $0.delegate = self }
        imagePickerController.delegate = self
    }
    
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
            
            if !aRect.contains(activeField!.frame.origin) {
                self.scrollView.scrollRectToVisible(activeField!.frame, animated: true)
            }
        }

    }
    
    // MARK: - Private Methods
    
    private func resetForm() {
        textFields.forEach { $0.hasError = false }
    }
    
}

// MARK: - UITextFieldDelegate

extension SignUpViewController: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        activeField = nil
        return true
    }
    
}

// MARK: - UIImagePickerControllerDelegate

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        profileImageView.image = selectedImage
        dismiss(animated: true)
    }
    
}
