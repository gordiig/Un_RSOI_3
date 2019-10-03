//
//  ApiCaller.swift
//  Un_RSOI_3
//
//  Created by Dmitry Gorin on 02.10.2019.
//  Copyright © 2019 gordiig. All rights reserved.
//

import Foundation


// MARK: - Errors
enum ApiCallerError: Error {
    case noTokenError
    case noHostGiven
    case wrongTokenError
    case incameError(code: Int, text: String)
}


// MARK: - Protocol
protocol ApiCaller {
    associatedtype Object: ApiObject
    
    var baseUsrStr: String? { get }
    var baseUrl: URL? { get }
    
    var tokenStr: String? { get }
    
    func getAll() -> Result<[Object], ApiCallerError>
    func getPaginated(paginationSuffix: String) -> Result<PaginatedApiObject<Object>, ApiCallerError>
    func getPaginated(limit: Int, offset: Int) -> Result<PaginatedApiObject<Object>, ApiCallerError>
    
    func get(id: UUID) -> Result<Object?, ApiCallerError>
    func get(id: Int) -> Result<Object?, ApiCallerError>
    
    func post(_ object: Object) -> Result<Object?, ApiCallerError>
    
    func patch(_ object: Object, newObject: Object) -> Result<Object?, ApiCallerError>
    
    func delete(_ object: Object) -> Result<Bool, ApiCallerError>

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
        guard let urlStr = baseUrlStr else {
            return nil
        }
        return URL(string: urlStr)
    }
    
    var tokenStr: String? {
        guard let token = UserData.instance.authToken else {
            return nil
        }
        return "Token \(token)"
    }
    
}
