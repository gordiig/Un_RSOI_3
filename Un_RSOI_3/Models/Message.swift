//
//  Message.swift
//  Un_RSOI_3
//
//  Created by Dmitry Gorin on 15.10.2019.
//  Copyright © 2019 gordiig. All rights reserved.
//

import Foundation
import Combine


// MARK: - Message class
class Message: ApiObject {
    fileprivate(set) var id: String
    @Published fileprivate(set) var text: String
    @Published fileprivate(set) var userFromId: Int
    @Published fileprivate(set) var userToId: Int
    @Published fileprivate(set) var imageId: String?
    @Published fileprivate(set) var audioId: String?
    
    var userFrom: User? {
        User.objects.get(id: userFromId)
    }
    var usernameFrom: String? {
        userFrom?.username
    }
    var userTo: User? {
        User.objects.get(id: userToId)
    }
    var usernameTo: String? {
        userTo?.username
    }
    var image: Image? {
        guard let imageId = imageId else { return nil }
        return Image.objects.get(id: imageId)
    }
    var audio: Audio? {
        guard let audioId = audioId else { return nil }
        return Audio.objects.get(id: audioId)
    }
    
    // MARK: - Inits
    init(text: String, userFromId: Int, userToId: Int, imageId: String?, audioId: String?) {
        self.id = ""
        self.text = text
        self.userFromId = userFromId
        self.userToId = userToId
        self.imageId = imageId
        self.audioId = audioId
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.text = try container.decode(String.self, forKey: .text)
        self.userToId = try container.decode(Int.self, forKey: .userToId)
        self.userFromId = try container.decode(Int.self, forKey: .userFromId)
        self.id = try container.decode(String.self, forKey: .id)
        self.imageId = try container.decode(String?.self, forKey: .imageId)
        self.audioId = try container.decode(String?.self, forKey: .audioId)
        let userFrom = try container.decode(User.self, forKey: .userFrom)
        User.objects.add(userFrom)
        let userTo = try container.decode(User.self, forKey: .userTo)
        User.objects.add(userTo)
        if let audio = try? container.decode(Audio.self, forKey: .audio) {
            Audio.objects.add(audio)
        }
        if let image = try? container.decode(Image.self, forKey: .image) {
            Image.objects.add(image)
        }
    }
    
    // MARK: - ApiObject implementation
    var isComplete: Bool {
        (imageId == nil && audioId == nil) || (image != nil || audio != nil)
    }
    static var objects: MessageManager { MessageManager.instance }
    
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id = "uuid"
        case text
        case userToId = "to_user_id"
        case userFromId = "from_user_id"
        case userFrom = "to_user"
        case userTo = "from_user"
        case imageId = "image_uuid"
        case audioId = "audio_uuid"
        case image
        case audio
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)
        try container.encode(imageId, forKey: .imageId)
        try container.encode(audioId, forKey: .audioId)
        try container.encode(userToId, forKey: .userToId)
    }
    
    func encodeForPost(withImage image: Image? = nil, withAudio audio: Audio? = nil) -> Data? {
        guard let msgData = try? JSONEncoder().encode(self) else {
            return nil
        }
        var msgDict = try! JSONSerialization.jsonObject(with: msgData) as! [String : Any]
        
        if let image = image {
            guard let imgData = try? JSONEncoder().encode(image) else {
                return nil
            }
            let imgDict = try! JSONSerialization.jsonObject(with: imgData) as! [String : Any]
            msgDict["image"] = imgDict
        }
        
        if let audio = audio {
            guard let audioData = try? JSONEncoder().encode(audio) else {
                return nil
            }
            let audioDict = try! JSONSerialization.jsonObject(with: audioData) as! [String : Any]
            msgDict["image"] = audioDict
        }
        
        return try! JSONSerialization.data(withJSONObject: msgDict)
    }
    
}


// MARK: - Object manager
class MessageManager: BaseApiObjectsManager<Message> {
    // Singletone work
    private static var _instance: MessageManager?
    fileprivate class var instance: MessageManager {
        if _instance == nil { _instance = MessageManager() }
        return _instance!
    }
    
    fileprivate override init() {
        super.init()
    }
    
    override var url: URL? {
        guard let ans = super.url else { return nil }
        return ans.appendingPathComponent("messages/")
    }
    
    override func override(_ object: Message, with: Message) {
//        object.id = with.id
        object.text = with.text
        object.imageId = with.imageId
        object.audioId = with.audioId
        object.userToId = with.userToId
        object.userFromId = with.userFromId
    }

}
