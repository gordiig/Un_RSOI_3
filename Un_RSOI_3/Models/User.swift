//
//  User.swift
//  Un_RSOI_3
//
//  Created by Dmitry Gorin on 15.10.2019.
//  Copyright © 2019 gordiig. All rights reserved.
//

import Foundation


// MARK: - User class
class User: ApiObject {
    private(set) var id: Int
    @Published private(set) var username: String
    @Published private(set) var email: String
    @Published private(set) var password: String = ""
    
    var isCurrentUser: Bool {
        return !password.isEmpty
    }
    
    // MARK: - Inits
    init(username: String, email: String) {
        self.username = username
        self.email = email
        self.id = 0
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.username = try container.decode(String.self, forKey: .username)
        self.email = try container.decode(String.self, forKey: .email)
    }
    
    // MARK: - ApiObject implementation
    var isComplete: Bool { true }
    static var objects: UserManager { UserManager.instance }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case email
        case password
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(username, forKey: .username)
        try container.encode(email, forKey: .email)
        try container.encode(password, forKey: .password)
    }
    
}


// MARK: - Object manager
class UserManager: BaseApiObjectsManager<User> {
    // Singletone work
    private static var _instance: UserManager?
    fileprivate class var instance: UserManager {
        if _instance == nil { _instance = UserManager() }
        return _instance!
    }
    
    fileprivate override init() {
        super.init()
    }
    
    override var url: URL? {
        guard let ans = super.url else { return nil }
        return ans.appendingPathComponent("users/")
    }

}
