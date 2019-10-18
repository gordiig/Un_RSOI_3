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
    @Published private(set) var id: UUID = UUID()
    @Published private(set) var text: String
    @Published private(set) var userFromId: Int
    @Published private(set) var userToId: Int
    @Published private(set) var imageId: UUID?
    @Published private(set) var audioId: UUID?
    
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
    init(text: String, userFromId: Int, userToId: Int, imageId: UUID, audioId: UUID) {
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
        let idStr = try container.decode(String.self, forKey: .id)
        self.id = UUID(uuidString: idStr)!
        let imgIdStr = try container.decode(String?.self, forKey: .imageId)
        self.imageId = (imgIdStr == nil) ? nil : UUID(uuidString: imgIdStr!)!
        let audioIdStr = try container.decode(String?.self, forKey: .audioId)
        self.audioId = (audioIdStr == nil) ? nil : UUID(uuidString: audioIdStr!)!
        let userFrom = try container.decode(User.self, forKey: .userFrom)
        User.objects.add(userFrom)
        let userTo = try container.decode(User.self, forKey: .userTo)
        User.objects.add(userTo)
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

}
