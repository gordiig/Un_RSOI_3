//
//  ApiObjectsService.swift
//  Un_RSOI_3
//
//  Created by Dmitry Gorin on 02.10.2019.
//  Copyright © 2019 gordiig. All rights reserved.
//

import Foundation
import Combine


typealias ApiObject = Identifiable & Hashable & Codable

// MARK: - Protocol
protocol ApiObjectsService {
    associatedtype Object: ApiObject
    
    var all: [Object] { get }
    
    func get(id: Object.ID) -> Object?
    func filter(_ predicate: (Object) -> Bool) -> [Object]
    
    func add(_ object: Object)
    func reset(_ objects: [Object])
    func delete(_ predicate: (Object) -> Bool)
    
    func patch(_ object: Object, to: Object)
    func exists(_ predicate: (Object) -> Bool) -> Bool
}


// MARK: - Defauld implementation
extension ApiObjectsService {
    func get(id: Object.ID) -> Object? {
        let filtered = all.filter { $0.id == id }
        if filtered.count == 1{
            return filtered[0]
        }
        return nil
    }
    
    func filter(_ predicate: (Object) -> Bool) -> [Object] {
        let filtered = all.filter { predicate($0) }
        return filtered
    }
    
    func exists(_ predicate: (Object) -> Bool) -> Bool {
        let filtered = all.filter { predicate($0) }
        return filtered.count > 0
    }
}


// MARK: - BaseApiObjectsService
class BaseApiObjectsService<T: ApiObject>: ApiObjectsService {
    // MARK: - Private variables and init
    fileprivate var _objects = [T]()
    
    fileprivate init() {
        
    }
    
    // MARK: - ApiObjectsService implementation
    var all: [T] {
        return _objects
    }
    
    func add(_ object: T) {
        if !exists { $0 == object } {
            _objects.append(object)
        }
    }
    
    func reset(_ objects: [T]) {
        _objects = objects
    }
    
    func delete(_ predicate: (T) -> Bool) {
        _objects.removeAll(where: predicate)
        // TODO: - Fix the stub
    }
    
    func patch(_ object: T, to: T) {
        // TODO: - Fix the stub
    }
}


// MARK: - AudiosService
class AudiosService: BaseApiObjectsService<Audio> {
    // MARK: - Singletone work
    private static var _instance: AudiosService?
    class var instance: AudiosService {
        if _instance == nil {
            _instance = AudiosService()
        }
        return _instance!
    }
    
    private override init() {
        super.init()
    }
    
}


// MARK: - ImagesService
class ImagesService: BaseApiObjectsService<Image> {
    // MARK: - Singletone work
    private static var _instance: ImagesService?
    class var instance: ImagesService {
        if _instance == nil {
            _instance = ImagesService()
        }
        return _instance!
    }
    
    private override init() {
        super.init()
    }
    
}


// MARK: - MessagesService
class MessagesService: BaseApiObjectsService<Message> {
    // MARK: - Singletone work
    private static var _instance: MessagesService?
    class var instance: MessagesService {
        if _instance == nil {
            _instance = MessagesService()
        }
        return _instance!
    }
    
    private override init() {
        super.init()
    }
    
}


// MARK: - UsersService
class UsersService: BaseApiObjectsService<User> {
    // MARK: - Singletone work
    private static var _instance: UsersService?
    class var instance: UsersService {
        if _instance == nil {
            _instance = UsersService()
        }
        return _instance!
    }
    
    private override init() {
        super.init()
    }
    
}
