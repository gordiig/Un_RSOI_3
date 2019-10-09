//
//  UserData.swift
//  Un_RSOI_3
//
//  Created by Dmitry Gorin on 02.10.2019.
//  Copyright © 2019 gordiig. All rights reserved.
//

import Foundation


class UserData {
    // MARK: - Singletone work
    private static var _intstance: UserData?
    class var instance: UserData {
        if _intstance == nil {
            _intstance = UserData()
        }
        return _intstance!
    }
    
    private init() {
        self.authToken = UserDefaults.standard.string(forKey: "authToken")
        self.selectedHost = UserDefaults.standard.string(forKey: "selectedHost")
        guard let userData = UserDefaults.standard.data(forKey: "currentUser") else {
            self.currentUser = nil
            return
        }
        self.currentUser = try? JSONDecoder().decode(User.self, from: userData)
    }
    
    // MARK: - Variables
    var currentUser: User? {
        didSet {
            let userData = try! JSONEncoder().encode(currentUser)
            UserDefaults.standard.set(userData, forKey: "currentUser")
        }
    }
    
    var authToken: String? {
        didSet{
            UserDefaults.standard.set(authToken, forKey: "authToken")
        }
    }
    
    var selectedHost: String? {
        didSet {
            UserDefaults.standard.set(selectedHost, forKey: "selectedHost")
        }
    }
}
