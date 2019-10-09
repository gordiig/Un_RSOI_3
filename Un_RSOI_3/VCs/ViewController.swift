//
//  ViewController.swift
//  Un_RSOI_3
//
//  Created by Dmitry Gorin on 09.10.2019.
//  Copyright © 2019 gordiig. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController, AlertPresentable, ApiAlertPresentable, KeyboardDismissable {
    // MARK: - IBOutlets
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var hostTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    // MARK: - Variables
    private let authService = AuthApiCaller.instance
    private let ud = UserData.instance
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardOnTouch()
        hostTextField.text = ud.selectedHost
    }

    // MARK: - IBActions
    @IBAction func logInButtonPressed(_ sender: Any) {
        ud.selectedHost = hostTextField.text
        // Getting input data
        guard let username = inputUsername else {
            alert(title: "No username", message: "You must add username to log in")
            return
        }
        guard let password = inputPassword else {
            alert(title: "No password", message: "You must add password to log in")
            return
        }
        
        authService.authenticate(username: username, password: password) { (result) in
            switch result {
            case .success(let newToken):
                self.ud.authToken = newToken
                self.alert(title: "Got token", message: "Now trying to get user info")
                // Getting user
                self.authService.userInfo { result in
                    switch result {
                    case .success(let user):
                        self.alert(title: "Got user")
                        self.ud.currentUser = user
                        // TODO: - Present main VC
                    case .failure(let err):
                        self.apiAlert(err)
                    }
                }
            case .failure(let err):
                self.apiAlert(err)
            }
        }
    }
    
    @IBAction func signUpButtonPressed(_ sender: Any) {
        ud.selectedHost = hostTextField.text
        // Getting input data
        guard let username = inputUsername else {
            alert(title: "No username", message: "You must add username to log in")
            return
        }
        guard let password = inputPassword else {
            alert(title: "No password", message: "You must add password to log in")
            return
        }
        
        authService.register(username: username, password: password) { result in
            switch result {
            case .success(let user):
                self.alert(title: "Sign up is done!")
                self.ud.currentUser = user
                // Getting token
                self.authService.authenticate(username: username, password: password) { result in
                    switch result {
                    case .success(let newToken):
                        self.alert(title: "Got token")
                        self.ud.authToken = newToken
                        // TODO: - Present main VC
                    case .failure(let err):
                        self.apiAlert(err)
                    }
                }
            case .failure(let err):
                self.apiAlert(err)
            }
        }
    }
    
    // MARK: - TextFieldGetters
    var inputUsername: String? {
        guard let username = usernameTextField.text else { return nil }
        if username.isEmpty { return nil }
        return username
    }
    
    var inputPassword: String? {
        guard let password = passwordTextField.text else { return nil }
        if password.isEmpty { return nil }
        return password
    }
    
}

