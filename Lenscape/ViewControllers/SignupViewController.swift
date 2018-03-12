//
//  SignupViewController.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 6/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Properties
    
    @IBOutlet private var textFields: [TextField]!
    
    @IBOutlet private weak var profileImageView: EnhancedUIImage!
    @IBOutlet private weak var firstNameTextField: TextField!
    @IBOutlet private weak var lastNameTextField: TextField!
    @IBOutlet private weak var emailTextField: TextField!
    @IBOutlet private weak var passwordTextField: TextField!
    @IBOutlet private weak var confirmPasswordTextField: TextField!
    
    
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
                if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") {
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
            }.catch { error in
                print(error)
        }
        
    }
    
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textFields.forEach { $0.delegate = self }
    }
    
    // MARK: - Private Methods
    
    private func resetForm() {
        textFields.forEach { $0.hasError = false }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
