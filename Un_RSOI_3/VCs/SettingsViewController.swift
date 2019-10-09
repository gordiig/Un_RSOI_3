//
//  SettingsViewController.swift
//  Un_RSOI_3
//
//  Created by Dmitry Gorin on 09.10.2019.
//  Copyright © 2019 gordiig. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, AlertPresentable {
    // MARK: - IBOutlets
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var hostTextField: UITextField!
    @IBOutlet weak var applyHostButton: UIButton!
    @IBOutlet weak var changeUserInfoButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        usernameLabel.text = UserData.instance.currentUser?.username
        emailLabel.text = UserData.instance.currentUser?.email
    }
    
    // MARK: - IBActions
    @IBAction func applyHostButtonPressed(_ sender: Any) {
        let host = hostTextField.text
        UserData.instance.selectedHost = host
    }
    
    @IBAction func logOutButtonPressed(_ sender: Any) {
        UserData.instance.authToken = nil
        UserData.instance.currentUser = nil
        guard let vc = storyboard?.instantiateViewController(identifier: "LogInVC") as? LogInViewController else {
            alert(title: "Can't instatiate LogInViewController")
            return
        }
        present(vc, animated: true)
    }
    
}
