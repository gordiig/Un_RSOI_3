//
//  TokenApiObject.swift
//  Un_RSOI_3
//
//  Created by Dmitry Gorin on 05.10.2019.
//  Copyright © 2019 gordiig. All rights reserved.
//

import Foundation


class TokenApiObject: ApiObject {
    // MARK: - Variables
    private(set) var token: String
    
    // MARK: - Init
    init(token: String) {
        self.token = token
    }
    
    // MARK: - Equatable (for hashable)
    static func == (lhs: TokenApiObject, rhs: TokenApiObject) -> Bool {
        return lhs.token == rhs.token
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(token)
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case token
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.token = try container.decode(String.self, forKey: .token)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(token, forKey: .token)
    }
}
