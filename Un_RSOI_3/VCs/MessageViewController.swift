//
//  MessageViewController.swift
//  Un_RSOI_3
//
//  Created by Dmitry Gorin on 09.10.2019.
//  Copyright © 2019 gordiig. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var messageTextLabel: UILabel!
    @IBOutlet weak var fromUserButton: UIButton!
    @IBOutlet weak var toUsernameButton: UIButton!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var audioButton: UIButton!
    
    // MARK: - Variables
    var message: Message!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - IBActions
    @IBAction func fromUserButtonPressed(_ sender: Any) {
    }
    
    @IBAction func toUserButtonPressed(_ sender: Any) {
    }
    
    @IBAction func imageButtonPressed(_ sender: Any) {
    }
    
    @IBAction func audioButtonPressed(_ sender: Any) {
    }
    
}
