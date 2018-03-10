//
//  SignupViewController.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 6/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //MARK: - Properties
    @IBOutlet private weak var profileImageView: EnhancedUIImage!
    @IBOutlet private weak var firstNameTextField: TextField!
    @IBOutlet private weak var lastNameTextField: TextField!
    @IBOutlet private weak var emailTextField: TextField!
    @IBOutlet private weak var passwordTextField: TextField!
    @IBOutlet private weak var confirmPasswordTextField: TextField!
    
    var api = Api()
    
    //MARK: - Computed properties
    private var isPasswordMatched: Bool {
        return confirmPasswordTextField.text == passwordTextField.text
    }
    
    private var isFormCompleted: Bool {
        if let firstName = firstNameTextField.text,
            let lastName = lastNameTextField.text,
            let email = emailTextField.text,
            let password = passwordTextField.text,
            let confirmPassword = confirmPasswordTextField.text {
            return !(firstName.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty)
        }
        return false
    }
    
    //MARK: - Actions
    @IBAction func signUp(_ sender: UIButton) {
        
        guard isFormCompleted else {
            //TODO: Handle incomplete forms.
            print("Form incomplete")
            firstNameTextField.hasError = true
            let emptyFields = getEmptyFields()
            for textField in emptyFields {
                textField.hasError = true
            }
            return
        }
        
        resetForm()
        
        guard isPasswordMatched else {
            //TODO: Handle unmatched password.
            print("Password doesn't match")
            return
        }
        let firstName = firstNameTextField.text!
        let lastName = lastNameTextField.text!
        let email = emailTextField.text!
        let password = passwordTextField.text!
        print(firstName, lastName, email, password)
        
        //TODO: Verification for each fields.
        //TODO: Send info to server with API.
        api.signUp(firstName: firstName, lastName: lastName, email: email, password: password).done {
            user in
            if UserController.saveUser(user: user) {
                if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController"){
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
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
    
    //MARK: - UITextFieldDelegate
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
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
    }
    
    // MARK: - Private Methods
    
    private func getEmptyFields() -> [TextField] {
        
        if isFormCompleted { return [] }
        
        var emptyFields = [TextField]()
        
        if firstNameTextField.text == nil {
            emptyFields.append(firstNameTextField)
        }
        if lastNameTextField.text == nil {
            emptyFields.append(lastNameTextField)
        }
        if passwordTextField.text == nil {
            emptyFields.append(passwordTextField)
        }
        if confirmPasswordTextField.text == nil {
            emptyFields.append(confirmPasswordTextField)
        }
        
        return emptyFields
        
    }
    
    private func resetForm() {
        firstNameTextField.hasError = false
        lastNameTextField.hasError = false
        emailTextField.hasError = false
        passwordTextField.hasError = false
        confirmPasswordTextField.hasError = false
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
