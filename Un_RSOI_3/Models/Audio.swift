//
//  Audio.swift
//  Un_RSOI_3
//
//  Created by Dmitry Gorin on 15.10.2019.
//  Copyright © 2019 gordiig. All rights reserved.
//

import Foundation


// MARK: - Audio class
class Audio: ApiObject {
    private(set) var id: UUID
    private(set) var name: String
    private(set) var length: Int
    
    // MARK: - Inits
    init(name: String, length: Int) {
        self.name = name
        self.length = length
        self.id = UUID()
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.length = try container.decode(Int.self, forKey: .length)
        let strId = try container.decode(String.self, forKey: .id)
        self.id = UUID(uuidString: strId)!
    }
    
    // MARK: - ApiObject implementation
    var isComplete: Bool { true }
    static var objects: AudioManager { AudioManager.instance }
    
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case length
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id.uuidString, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(length, forKey: .length)
    }
    
}


// MARK: - Object manager
class AudioManager: BaseApiObjectsManager<Audio> {
    // Singletone work
    private static var _instance: AudioManager?
    class var instance: AudioManager {
        if _instance == nil { _instance = AudioManager() }
        return _instance!
    }
    
    fileprivate override init() {
        super.init()
    }
    
    override var url: URL? {
        guard let ans = super.url else { return nil }
        return ans.appendingPathComponent("auido/")
    }

}
