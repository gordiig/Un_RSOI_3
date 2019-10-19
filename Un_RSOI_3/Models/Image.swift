//
//  Image.swift
//  Un_RSOI_3
//
//  Created by Dmitry Gorin on 15.10.2019.
//  Copyright © 2019 gordiig. All rights reserved.
//

import Foundation


// MARK: - Image class
class Image: ApiObject {
    @Published private(set) var id: String
    @Published private(set) var name: String
    @Published private(set) var width: Int
    @Published private(set) var height: Int
    
    // MARK: - Inits
    init(name: String, width: Int, height: Int) {
        self.name = name
        self.width = width
        self.height = height
        self.id = ""
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        
        self.id = try container.decode(String.self, forKey: .id)
        
        let sizeStr = try container.decode(String.self, forKey: .imageSize)
        let wh = sizeStr.split(separator: "x").map { Int(String($0))! }
        self.width = wh[0]
        self.height = wh[1]
    }
    
    // MARK: - ApiObject implementation
    var isComplete: Bool { true }
    static var objects: ImageManager { ImageManager.instance }
    
    func complete(_ obj: Image) {
        return
    }
    
    func complete(with data: Data) throws {
        return
    }
    
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id = "uuid"
        case name
        case width
        case height
        case imageSize = "image_size"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(width, forKey: .width)
        try container.encode(height, forKey: .height)
    }
    
}


// MARK: - Object manager
class ImageManager: BaseApiObjectsManager<Image> {
    // Singletone work
    private static var _instance: ImageManager?
    fileprivate class var instance: ImageManager {
        if _instance == nil { _instance = ImageManager() }
        return _instance!
    }
    
    fileprivate override init() {
        super.init()
    }
    
    override var url: URL? {
        guard let ans = super.url else { return nil }
        return ans.appendingPathComponent("image/")
    }

}
