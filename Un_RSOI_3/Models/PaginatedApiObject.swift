//
//  PaginatedApiObject.swift
//  Un_RSOI_3
//
//  Created by Dmitry Gorin on 02.10.2019.
//  Copyright © 2019 gordiig. All rights reserved.
//

import Foundation


class PaginatedApiObject<T: ApiObject>: ApiObject {
    // MARK: - Variables
    private(set) var next: String
    private(set) var previous: String
    private(set) var results: [T]
    
    // MARK: - Init
    init(next: String, previous: String, results: [T]) {
        self.next = next
        self.previous = previous
        self.results = results
    }
    
    // MARK: - Equatable (for hashable)
    static func == (lhs: PaginatedApiObject, rhs: PaginatedApiObject) -> Bool {
        return false
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(next)
        hasher.combine(previous)
        hasher.combine(results)
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case next
        case previous
        case results
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.next = try container.decode(String.self, forKey: .next)
        self.previous = try container.decode(String.self, forKey: .previous)
        self.results = try container.decode([T].self, forKey: .results)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(next, forKey: .next)
        try container.encode(previous, forKey: .previous)
        try container.encode(results, forKey: .results)
    }
    
}
