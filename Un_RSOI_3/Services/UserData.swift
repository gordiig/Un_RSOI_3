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
        self.currentUser = UserDefaults.standard.value(forKey: "currentUser") as? User
        self.selectedHost = UserDefaults.standard.string(forKey: "selectedHost")
    }
    
    // MARK: - Variables
    var currentUser: User? {
        didSet {
            UserDefaults.standard.set(currentUser, forKey: "currentUser")
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
