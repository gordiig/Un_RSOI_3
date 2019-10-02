//
//  ApiError.swift
//  Un_RSOI_3
//
//  Created by Dmitry Gorin on 02.10.2019.
//  Copyright © 2019 gordiig. All rights reserved.
//

import Foundation


class ApiError: ApiObject {
    // MARK: - Variables
    private(set) var text: String
    
    // MARK: - Init
    init(text: String) {
        self.text = text
    }
    
    // MARK: - Equatable (for hashable)
    static func == (lhs: ApiError, rhs: ApiError) -> Bool {
        return lhs.text == rhs.text
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(text)
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case text = "error"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.text = try container.decode(String.self, forKey: .text)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(text, forKey: .text)
    }
}
