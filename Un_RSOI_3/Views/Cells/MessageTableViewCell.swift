//
//  MessageTableViewCell.swift
//  Un_RSOI_3
//
//  Created by Dmitry Gorin on 09.10.2019.
//  Copyright © 2019 gordiig. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {
    // MARK: - IBOutlets
    @IBOutlet weak var messageTextLabel: UILabel!
    
    // MARK: - Variables
    static var id = "MessageCell"
    var message: Message! {
        didSet {
            messageTextLabel.text = message.text
        }
    }

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setUp(_ message: Message) {
        self.message = message
    }

}
