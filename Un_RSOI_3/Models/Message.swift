//
//  Message.swift
//  Un_RSOI_3
//
//  Created by Dmitry Gorin on 02.10.2019.
//  Copyright © 2019 gordiig. All rights reserved.
//

import Foundation


class Message: Identifiable, Hashable, Codable {
    // MARK: - Variables
    let id: UUID
    private(set) var text: String
    private(set) var fromUserId: Int
    private(set) var toUserId: Int
    private(set) var imageId: UUID?
    private(set) var audioId: UUID?
    
    // MARK: - Inits
    init(id: UUID, text: String, fromUserId: Int, toUserId: Int, imageId: UUID? = nil, audioId: UUID? = nil)
    {
        self.id = id
        self.text = text
        self.fromUserId = fromUserId
        self.toUserId = toUserId
        self.imageId = imageId
        self.audioId = audioId
    }
    
    // MARK: - Getters
    // TODO: - Stubs
    var userFrom: User {
        return User()
    }
    
    var userTo: User {
        return User()
    }
    
    // MARK: - Equatable (for hashable)
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(fromUserId)
        hasher.combine(toUserId)
        hasher.combine(imageId)
        hasher.combine(audioId)
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id = "uuid"
        case text
        case fromUserId = "from_user_id"
        case toUserId = "to_user_id"
        case imageId = "image_uuid"
        case audioId = "audio_uuid"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.text = try container.decode(String.self, forKey: .text)
        self.fromUserId = try container.decode(Int.self, forKey: .fromUserId)
        self.toUserId = try container.decode(Int.self, forKey: .toUserId)
        
        let imgUuidStr = try container.decode(String?.self, forKey: .imageId)
        self.imageId = UUID(uuidString: imgUuidStr ?? "")
        
        let audioUuidStr = try container.decode(String?.self, forKey: .audioId)
        self.audioId = UUID(uuidString: audioUuidStr ?? "")
        
        let uuidStr = try container.decode(String.self, forKey: .id)
        self.id = UUID(uuidString: uuidStr)!
    }
}
