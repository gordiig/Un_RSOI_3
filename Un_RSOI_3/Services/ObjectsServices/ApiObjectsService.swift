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
    associatedtype Objects = [Object]
    
    var all: Objects { get }
    
    func get(id: Object.ID) -> Object
    func filter(_ predicate: (Object) -> Bool) -> Objects
    
    func add(_ object: Object)
    func delete(_ predicate: (Object) -> Bool)
    
    func patch(_ object: Object, to: Object)
    func exists(_ predicate: (Object) -> Bool) -> Bool
}
