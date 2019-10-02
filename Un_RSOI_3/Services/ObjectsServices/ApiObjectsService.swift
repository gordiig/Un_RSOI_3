//
//  ApiObjectsService.swift
//  Un_RSOI_3
//
//  Created by Dmitry Gorin on 02.10.2019.
//  Copyright © 2019 gordiig. All rights reserved.
//

import Foundation


protocol ApiObjectsService {
    associatedtype Object: Identifiable
    associatedtype Objects where Objects == [Object]
    
    var all: Objects { get }
    
    func get(id: Object.ID) -> Object?
    func filter(_ predicate: (Object) -> Bool) -> Objects
    
    func add(_ object: Object)
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
    
    func filter(_ predicate: (Object) -> Bool) -> Objects {
        let filtered = all.filter { predicate($0) }
        return filtered
    }
    
    func exists(_ predicate: (Object) -> Bool) -> Bool {
        let filtered = all.filter { predicate($0) }
        return filtered.count > 0
    }
}
