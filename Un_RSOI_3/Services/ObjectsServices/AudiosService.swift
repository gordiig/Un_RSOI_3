//
//  AudiosService.swift
//  Un_RSOI_3
//
//  Created by Dmitry Gorin on 02.10.2019.
//  Copyright © 2019 gordiig. All rights reserved.
//

import Foundation


class AudiosService: ApiObjectsService {
    // MARK: - Singletone work
    private static var _instance: AudiosService?
    class var instance: AudiosService {
        if _instance == nil {
            _instance = AudiosService()
        }
        return _instance!
    }
    
    private init() {
        
    }
    
    
}
