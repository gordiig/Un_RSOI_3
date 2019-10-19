//
//  ViewController.swift
//  Un_RSOI_3
//
//  Created by Dmitry Gorin on 09.10.2019.
//  Copyright © 2019 gordiig. All rights reserved.
//

import UIKit
import SwiftUI
import Combine

class LogInViewController: UIViewController, AlertPresentable, ApiAlertPresentable {
    // MARK: - IBOutlets
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var hostTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    // MARK: - Variables
    private let authService = AuthService.instance
    private let ud = UserData.instance
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        hostTextField.text = ud.selectedHost
        usernameTextField.text = ud.currentUser?.username ?? ""
    }
    
    // MARK: - Hide keyboard on tap
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
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
        
        let _ = authService.authenticate(username: username, password: password)
            .sink(receiveCompletion: { (comletion) in
                switch comletion {
                case .failure(let err):
                    self.apiAlert(err)
                    return
                case .finished:
                    return
                }
                }) { (token) in
                    UserData.instance.authToken = token
                    // TODO: get user by token
                    UserData.instance.currentUser = User(username: username, email: "")
                    self.presentMessagesVC()
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
        
        let _ = authService.register(username: username, password: password)
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .failure(let err):
                    self.apiAlert(err)
                    return
                case .finished:
                    return
            }
            }) { (user) in
                User.objects.add(user)
                self.alert(title: "Registration passed successfully!")
            }
    }
    
    // MARK: - Present MessagesVC
    func presentMessagesVC() {
        let vc = UIHostingController(rootView: MainTabBarView())
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
}

