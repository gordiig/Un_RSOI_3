//
//  ViewController.swift
//  Un_RSOI_3
//
//  Created by Dmitry Gorin on 09.10.2019.
//  Copyright © 2019 gordiig. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {
    // MARK: - IBOutlets
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    // MARK: - Variables
    private let authService = AuthApiCaller.instance
    private let ud = UserData.instance
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    // MARK: - IBActions
    @IBAction func logInButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func signUpButtonPressed(_ sender: Any) {
        
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

