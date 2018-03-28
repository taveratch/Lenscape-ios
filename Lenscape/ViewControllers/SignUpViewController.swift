//
//  SignupViewController.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 6/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit
import Validator

class SignUpViewController: UIViewController {
    
    // MARK: - UI Components
    
    @IBOutlet private var textFields: [TextField]!
    @IBOutlet private weak var profileImageView: EnhancedUIImage!
    @IBOutlet private weak var firstNameTextField: TextField!
    @IBOutlet private weak var lastNameTextField: TextField!
    @IBOutlet private weak var emailTextField: TextField!
    @IBOutlet private weak var passwordTextField: TextField!
    @IBOutlet private weak var confirmPasswordTextField: TextField!
    @IBOutlet private weak var signUpButton: UIButton!
    @IBOutlet private weak var scrollView: UIScrollView!
    var activeField: UITextField?
    private lazy var imagePickerController = UIImagePickerController()
    
    
    // MARK: - Computed properties
    
    private var isFormCompleted: Bool {
        return textFields.filter { !$0.hasText }.isEmpty
    }
    
    // MARK: - Actions
    
    @IBAction func signUp(_ sender: UIButton) {
        
        guard isFormCompleted else {
            textFields.filter { !$0.hasText }.forEach { $0.hasError = true }
            return
        }
        
        signUpButton.setTitle("", for: .normal)
        signUpButton.loadingIndicator(show: true)

        Api.signUp(
            picture: profileImageView.image,
            firstName: firstNameTextField.text!,
            lastName: lastNameTextField.text!,
            email: emailTextField.text!,
            password: passwordTextField.text!
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
        setupKeyboard()
        setupValidation()
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
    
    private func setupValidation() {
        
        // MARK: Email Validation
        // 1. Required
        // 2. Valid email pattern
        var emailRules = ValidationRuleSet<String>()
        emailRules.add(rule: ValidationRuleCondition<String>(
            error: ValidationError.required,
            condition: { _ in self.emailTextField.hasText }
        ))
        emailRules.add(rule: ValidationRulePattern(
            pattern: EmailValidationPattern.standard,
            error: ValidationError.invalidInput("Please use a valid email")
        ))
        emailTextField.validationRules = emailRules
        emailTextField.validationHandler = makeValidationHandler(for: emailTextField)
        emailTextField.validateOnEditingEnd(enabled: true)
        
        // MARK: Password Validation
        // 1. Required
        // 2. More than 6 characters
        // 3. Have at least 1 number
        var passwordRules = ValidationRuleSet<String>()
        passwordRules.add(rule: ValidationRuleCondition<String>(
            error: ValidationError.required,
            condition: { $0 != nil }
        ))
        passwordRules.add(rule: ValidationRuleLength(
            min: 6,
            error: ValidationError.invalidInput("Password needs to be longer than 6 characters")
        ))
        passwordRules.add(rule: ValidationRulePattern(
            pattern: ContainsNumberValidationPattern(),
            error: ValidationError.invalidInput("Password needs to have at least 1 number")
        ))
        passwordTextField.validationRules = passwordRules
        passwordTextField.validationHandler = makeValidationHandler(for: passwordTextField)
        passwordTextField.validateOnEditingEnd(enabled: true)
        
        // MARK: Confirm password
        // 1. Required
        // 2. Match the password
        var confirmPasswordRules = ValidationRuleSet<String>()
        confirmPasswordRules.add(rule: ValidationRuleCondition<String>(
            error: ValidationError.required,
            condition: { $0 != nil }
        ))
        confirmPasswordRules.add(rule: ValidationRuleEquality<String>(
            dynamicTarget: { return self.passwordTextField.text ?? "" },
            error: ValidationError.invalidInput("Password doesn't match")
        ))
        confirmPasswordTextField.validationRules = confirmPasswordRules
        confirmPasswordTextField.validationHandler = makeValidationHandler(for: confirmPasswordTextField)
        confirmPasswordTextField.validateOnEditingEnd(enabled: true)
    }
    
    private func makeValidationHandler(for textField: TextField) -> ((ValidationResult) -> Void) {
        return { result in
            switch result {
            case .valid:
                textField.isValidated = true
            case .invalid(let errors):
                textField.hasError = true
                self.showValidationError(errors)
            }
        }
    }
    
    private func showValidationError(_ errors: [Error]) {
        var errorMessage: [String] = []
        if let errors = errors as? [ValidationError] {
            outerLoop: for error in errors {
                switch error {
                case .required:
                    errorMessage.append("This field is required")
                    break outerLoop
                case .invalidInput(let message):
                    errorMessage.append(message)
                }
            }
        }
        
        let alert = UIAlertController(
            title: nil,
            message: errorMessage.joined(separator: "\n"),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
            // https://stackoverflow.com/questions/5143873/dismissing-the-keyboard-in-a-uiscrollview?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
    private func setupKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(tapGesture)
    }
    
    private func resetForm() {
        textFields.forEach { $0.hasError = false }
        signUpButton.loadingIndicator(show: false)
    }
    
    @objc private func hideKeyboard() {
        textFields.forEach { $0.resignFirstResponder() }
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
