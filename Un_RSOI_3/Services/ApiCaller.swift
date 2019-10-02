//
//  ApiCaller.swift
//  Un_RSOI_3
//
//  Created by Dmitry Gorin on 02.10.2019.
//  Copyright © 2019 gordiig. All rights reserved.
//

import Foundation


protocol ApiCaller {
    var baseUsrStr: String? { get }
    var baseUrl: URL? { get }
    
    func getAll<T: ApiObject>() -> [T]
    func get<T: ApiObject>(id: UUID) -> T?
    func get<T: ApiObject>(id: Int) -> T?
    
    func post<T: ApiObject>(_ object: T) -> T?
    
    func patch<T: ApiObject>(_ object: T, newObject: T) -> T?
    
    func delete<T: ApiObject>(_ object: T) -> Bool
    
}


// MARK: - Default implementation
extension ApiCaller {
    var baseUrlStr: String? {
        guard let host = UserData.instance.selectedHost else {
            return nil
        }
        return "http://\(host):8000/"
    }
    
    var baseUrl: URL? {
        return URL(string: baseUrlStr ?? "")
    }
    
}
