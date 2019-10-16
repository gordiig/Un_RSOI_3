//
//  ViewController.swift
//  Un_RSOI_3
//
//  Created by Dmitry Gorin on 09.10.2019.
//  Copyright © 2019 gordiig. All rights reserved.
//

import UIKit
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
    private var valueSubscriber: AnyCancellable!
    private var errorSubscriber: AnyCancellable!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        hostTextField.text = ud.selectedHost
        
        valueSubscriber = authService.publisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { (val) in
                if val {
                    self.presentMessagesVC()
                } else {
                    self.alert(title: "False came from publisher", message: "That's strange...")
                }
            })
        
        errorSubscriber = authService.errorPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { (err) in
                self.apiAlert(err)
            })
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
        
        authService.authenticate(username: username, password: password)
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
        
        authService.register(username: username, password: password)
    }
    
    // MARK: - Present MessagesVC
    func presentMessagesVC() {
        guard let vc = storyboard?.instantiateViewController(identifier: MessagesViewController.storyboardID) as? MessagesViewController else {
            alert(title: "Can't instatiate MessagesViewController")
            return
        }
        let navVc = UINavigationController(rootViewController: vc)
        navVc.modalPresentationStyle = .fullScreen
        navVc.navigationBar.prefersLargeTitles = true
        present(navVc, animated: true)
    }
    
}

