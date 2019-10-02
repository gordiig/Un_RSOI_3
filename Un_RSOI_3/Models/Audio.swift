//
//  Audio.swift
//  Un_RSOI_3
//
//  Created by Dmitry Gorin on 02.10.2019.
//  Copyright © 2019 gordiig. All rights reserved.
//

import Foundation


class Audio: ApiObject {
    // MARK: - Variables
    let id: UUID
    private(set) var name: String
    private(set) var length: Int
    
    // MARK: - Inits
    init(id: UUID, name: String, length: Int) {
        self.id = id
        self.name = name
        self.length = length
    }
    
    // MARK: - Equatable (for hashable)
    static func == (lhs: Audio, rhs: Audio) -> Bool {
        return lhs.id == rhs.id
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(length)
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id = "uuid"
        case name
        case length
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.length = try container.decode(Int.self, forKey: .length)
        let strUuid = try container.decode(String.self, forKey: .id)
        self.id = UUID(uuidString: strUuid)!
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id.uuidString, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(length, forKey: .length)
    }
    
}

