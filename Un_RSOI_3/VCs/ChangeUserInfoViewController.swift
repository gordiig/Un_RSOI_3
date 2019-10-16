//
//  ChangeUserInfoViewController.swift
//  Un_RSOI_3
//
//  Created by Dmitry Gorin on 09.10.2019.
//  Copyright © 2019 gordiig. All rights reserved.
//

import UIKit

class ChangeUserInfoViewController: UIViewController, AlertPresentable, ApiAlertPresentable {
    // MARK: - IBOutlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    // MARK: - Variables
    private let ud = UserData.instance
    private let userManager = User.objects
    
    // MARK: - TextField getters
    var username: String? {
        guard let username = usernameTextField.text else { return nil }
        if username.isEmpty { return nil }
        return username
    }
    
    var email: String? {
        guard let email = emailTextField.text else { return nil }
        if email.isEmpty { return nil }
        return email
    }
    
    var password: String? {
        guard let password = passwordTextField.text else { return nil }
        if password.isEmpty { return nil }
        return password
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - IBActions
    @IBAction func submitButtonPressed(_ sender: Any) {
        guard let username = username, let email = email, let password = password else {
            alert(title: "Enter all fields for update")
            return
        }
        guard let user = ud.currentUser else {
            alert(title: "No current user", message: "Log out and log in again")
            return
        }
    }
    
}
