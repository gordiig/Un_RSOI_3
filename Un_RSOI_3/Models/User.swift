//
//  User.swift
//  Un_RSOI_3
//
//  Created by Dmitry Gorin on 02.10.2019.
//  Copyright © 2019 gordiig. All rights reserved.
//

import Foundation


class User: ApiObject {
    // MARK: - Variables
    let id: Int
    private(set) var username: String
    private(set) var email: String
    
    // MARK: - Inits
    init(id: Int, username: String, email: String) {
        self.id = id
        self.username = username
        self.email = email
    }
    
    // MARK: - Equatable (for hashable)
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(username)
        hasher.combine(email)
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case email
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.username = try container.decode(String.self, forKey: .username)
        self.email = try container.decode(String.self, forKey: .email)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(username, forKey: .username)
        try container.encode(email, forKey: .email)
    }
    
}
