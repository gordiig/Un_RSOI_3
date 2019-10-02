//
//  Image.swift
//  Un_RSOI_3
//
//  Created by Dmitry Gorin on 02.10.2019.
//  Copyright © 2019 gordiig. All rights reserved.
//

import Foundation


class Image: ApiObject {
    // MARK: - Variables
    let id: UUID
    private(set) var name: String
    private(set) var width: Int
    private(set) var height: Int
    
    // MARK: - Inits
    init(id: UUID, name: String, width: Int, height: Int) {
        self.id = id
        self.name = name
        self.width = width
        self.height = height
    }
    
    // MARK: - Equatable (for hashable)
    static func == (lhs: Image, rhs: Image) -> Bool {
        return lhs.id == rhs.id
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(width)
        hasher.combine(height)
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id = "uuid"
        case name
        case image_size
        case width
        case height
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        let imgSize = try container.decode(String.self, forKey: .image_size)
        let sizes = imgSize.split(separator: "x").map { String($0) }
        self.width = Int(sizes[0])!
        self.height = Int(sizes[1])!
        let uuidStr = try container.decode(String.self, forKey: .id)
        self.id = UUID(uuidString: uuidStr)!
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(width, forKey: .width)
        try container.encode(height, forKey: .height)
        try container.encode(id, forKey: .id)
    }

}
