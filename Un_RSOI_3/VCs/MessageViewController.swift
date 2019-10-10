//
//  MessageViewController.swift
//  Un_RSOI_3
//
//  Created by Dmitry Gorin on 09.10.2019.
//  Copyright © 2019 gordiig. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController, AlertPresentable {
    // MARK: - IBOutlets
    @IBOutlet weak var messageTextLabel: UILabel!
    @IBOutlet weak var fromUserButton: UIButton!
    @IBOutlet weak var toUsernameButton: UIButton!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var audioButton: UIButton!
    
    // MARK: - Variables
    var message: Message!
    private var image: Image?
    private var audio: Audio?
    private var userTo: User?
    private var userFrom: User?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Set up
    func setUp(_ message: Message) {
        self.message = message
        messageTextLabel.text = message.text
        // Images
        if let imageId = message.imageId {
            getImage(imageId: imageId)
        } else {
            setButtonText(imageButton, label: nil)
        }
        // Audio
        if let audioId = message.audioId {
            getAudio(audioId: audioId)
        } else {
            setButtonText(audioButton, label: nil)
        }
        // UserTo
        getUserTo(userId: message.toUserId)
        // UserFrom
        getUserFrom(userId: message.fromUserId)
    }
    
    private func setButtonText(_ button: UIButton, label: String?) {
        if let label = label {
            button.titleLabel?.text = label
            button.isEnabled = true
        } else {
            button.titleLabel?.text = "No content"
            button.isEnabled = false
        }
    }
    
    private func getImage(imageId: UUID) {
        let img = ImagesService.instance.get(id: imageId)
        if img != nil {
            self.image = img!
            setButtonText(imageButton, label: img!.name)
            return
        }
        ImagesApiCaller.instance.get(id: imageId.uuidString) { (result) in
            switch result {
            case .success(let img):
                ImagesService.instance.add(img)
                self.image = img
                self.setButtonText(self.imageButton, label: img.name)
                return
                
            case .failure:
                self.alert(title: "Error with getting image")
                self.setButtonText(self.imageButton, label: nil)
                return
            }
        }
    }
    
    private func getAudio(audioId: UUID) {
        let audio = AudiosService.instance.get(id: audioId)
        if audio != nil {
            self.audio = audio
            self.setButtonText(self.audioButton, label: audio!.name)
            return
        }
        AudiosApiCaller.instance.get(id: audioId.uuidString) { (result) in
            switch result {
            case .success(let audio):
                AudiosService.instance.add(audio)
                self.audio = audio
                self.setButtonText(self.audioButton, label: audio.name)
                return
                
            case .failure:
                self.alert(title: "Error with getting audio")
                self.setButtonText(self.audioButton, label: nil)
                return
            }
        }
    }
    
    private func getUserTo(userId: Int) {
        let user = UsersService.instance.get(id: userId)
        if user != nil {
            self.userTo = user
            self.setButtonText(self.toUsernameButton, label: user!.username)
            return
        }
        UsersApiCaller.instance.get(id: String(userId)) { (result) in
            switch result {
            case .success(let user):
                UsersService.instance.add(user)
                self.userTo = user
                self.setButtonText(self.toUsernameButton, label: user.username)
                return
                
            case .failure:
                self.alert(title: "Error with getting user to")
                self.setButtonText(self.toUsernameButton, label: nil)
                return
            }
        }
    }
    
    private func getUserFrom(userId: Int) {
        let user = UsersService.instance.get(id: userId)
        if user != nil {
            self.userFrom = user
            self.setButtonText(self.fromUserButton, label: user!.username)
            return
        }
        UsersApiCaller.instance.get(id: String(userId)) { (result) in
            switch result {
            case .success(let user):
                UsersService.instance.add(user)
                self.userFrom = user
                self.setButtonText(self.fromUserButton, label: user.username)
                return
                
            case .failure:
                self.alert(title: "Error with getting user from")
                self.setButtonText(self.fromUserButton, label: nil)
                return
            }
        }
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
