//
//  SignupViewController.swift
//  MainTrack-Prototype
//
//  Created by Clay Suttner on 3/10/21.
//

import UIKit
import FirebaseAuth

class SignupViewController: UIViewController {
    
    let signUpView = SignUpView()
    let apiClient = ApiClient.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        setupSubviews()
        addTapGesture()
        addButtonActions()
    }
    
    private func setupSubviews() {
        view.addSubview(signUpView)
        signUpView.anchor(
            centerX: view.centerXAnchor,
            centerY: view.centerYAnchor,
            width: .loginViewWidth
        )
    }
    
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(onTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func onTap() {
        signUpView.dismissKeyboard()
    }
    
    private func addButtonActions() {
        signUpView.submitButton.addTarget(self, action: #selector(onSubmitButtonTapped), for: .touchUpInside)
        signUpView.cancelButton.addTarget(self, action: #selector(onCancelButtonTapped), for: .touchUpInside)
    }
    
    private func getUserDataFromInput() throws -> UserData {
        guard let email = signUpView.emailText.text, !email.isEmpty,
              let password = signUpView.passwordText.text, !password.isEmpty,
              let reenterPassword = signUpView.reenterPasswordText.text, !reenterPassword.isEmpty,
              let roleString = signUpView.roleText.text, !roleString.isEmpty
        else {
            throw ValidationError.missingData
        }
        
        guard password == reenterPassword else { throw ValidationError.passwordMismatch }
        
        guard let role = Role(rawValue: roleString) else { throw ValidationError.roleNotFound }
        
        return UserData(email, password, role)
    }
    
    @objc func onSubmitButtonTapped() {
        do {
            let newUserData = try getUserDataFromInput()
            tryAdding(newUser: newUserData)
        } catch let error {
            presentBasicAlert(title: "Error signing up", message: error.localizedDescription)
        }
    }
    
    func tryAdding(newUser: UserData) {
        apiClient.checkUserExists(with: newUser.email) { userExists in
            if userExists {
                self.presentBasicAlert(title: "An account already exists for \(newUser.email)")
            } else {
                self.createNewUser(newUser: newUser)
            }
        }
    }
    
    func createNewUser(newUser: UserData) {
        Auth.auth().createUser(withEmail: newUser.email, password: newUser.password) { (result, error) in
            if error != nil {
                print("Error adding new user \(newUser.email)")
            } else {
                print("Added user \(newUser.email)")
                self.apiClient.post(newUser)
                self.presentReturningAlert(title: "Success!", message: "You'll be redirected to sign in")
            }
        }
    }
    
    @objc func onCancelButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
