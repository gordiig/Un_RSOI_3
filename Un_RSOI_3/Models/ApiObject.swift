//
//  ApiObject.swift
//  Un_RSOI_3
//
//  Created by Dmitry Gorin on 15.10.2019.
//  Copyright © 2019 gordiig. All rights reserved.
//

import Foundation
import Combine


// MARK: - ApiObject
protocol ApiObject: Codable, Identifiable {
    associatedtype Manager: ApiObjectsManager
    
    var isComplete: Bool { get }
    static var objects: Manager { get }
    
}


// MARK: - Manager
protocol ApiObjectsManager {
    associatedtype Object: ApiObject
    
    // MARK: - All-local calls
    /// Publisher for updates subscribing
    var publisher: PassthroughSubject<Void, Never> { get }
    
    /// Publisher for errors
    var errorPublisher: PassthroughSubject<ApiObjectsManagerError, Never> { get }
    
    /// Returns all the object that are in-memory
    var all: [Object] { get }
    
    
    /// Gets object with given id
    /// - Parameter id: Identificator of the object
    func get(id: Object.ID) -> Object?
    
    
    /// Filters objects that are in-memory
    /// - Parameter predicate: Filtering predicate
    func filter(_ predicate: (Object) -> Bool) -> [Object]
    
    
    /// Adding new object locally (DO THIS ONLY IF YOU GOT OBJECT FROM SERVER)
    /// - Parameter object: Object to be added
    func add(_ object: Object)
    
    /// Returns true if manager has given object
    /// - Parameter object: Object to be found
    func exist(_ object: Object) -> Bool
    
    /// Clears local memory by deleting all object
    func clear()
    
    /// Locally deletes object with given ID
    /// - Parameter id: ID of the object to be removed
    func clear(id: Object.ID)
    
    
    // MARK: - Semi-local calls
    /// Deletes object on server, and then locally
    /// - Parameter id: ID of the object to be removed
    func delete(id: Object.ID)
    
    
    /// Fetches object with given ID
    /// - Parameter id: ID of the object to be fetched
    func fetch(id: Object.ID)
    
    /// Fetches objects with limit-offset pagination
    /// - Parameter limit: Limit for pagination
    /// - Parameter offset: Offset for pagination
    func fetch(limit: Int, offset: Int)
    
    /// Fetches all objects from server
    func fetchAll()

}


// MARK: - Errors
enum ApiObjectsManagerError: Error {
    case noHostGiven
    case noTokenGiven
    case decodeError
    case encodeError
    case unknownError
    case codedError(code: Int, message: String = "No message")
    
}

// MARK: - BaseManager class
/// Override url property and make it singleton
class BaseApiObjectsManager<T: ApiObject>: ApiObjectsManager {
    // MARK: - Variables
    var objects = [T]() {
        didSet {
            publisher.send()
        }
    }
    var url: URL? {
        guard let host = UserData.instance.selectedHost else { return nil }
        return URL(string: "http://\(host):8000/api/")
    }
    
    // MARK: - Locals imlementation
    var publisher = PassthroughSubject<Void, Never>()
    var errorPublisher = PassthroughSubject<ApiObjectsManagerError, Never>()
    
    var all: [T] {
        return objects
    }
    
    func get(id: T.ID) -> T? {
        let filtered = filter { $0.id == id }
        if filtered.isEmpty { return nil }
        return filtered[0]
    }
    func filter(_ predicate: (T) -> Bool) -> [T] {
        let filtered = objects.filter(predicate)
        return filtered
    }
    
    func add(_ object: T) {
        if exist(object) {
            return
        }
        objects.append(object)
    }
    
    func exist(_ object: T) -> Bool {
        return objects.contains(where: { $0.id == object.id })
    }
    
    func clear() {
        objects = []
    }
    func clear(id: T.ID) {
        objects.removeAll { $0.id == id }
    }
    
    // MARK: - Semi-local implementation
    func fetch(id: T.ID) {
        let requestResult = getRequest(method: "GET", urlPostfix: "\(id)/")
        var request: URLRequest
        switch requestResult {
        case .failure(let err):
            errorPublisher.send(err)
            return
        case .success(let requestSuccsess):
            request = requestSuccsess
        }
        
        let _ = URLSession.shared.dataTask(with: request) { (data, response, _) in
            guard let data = data, let response = response else {
                self.errorPublisher.send(ApiObjectsManagerError.unknownError)
                return
            }
            self.computeResponsePublisherFunc(data: data, response: response, method: .getConcrete(id: id))
        }
    }
    
    func fetch(limit: Int, offset: Int) {
        let requestResult = getRequest(method: "GET", urlPostfix: "?limit=\(limit)&offset=\(offset)")
        var request: URLRequest
        switch requestResult {
        case .failure(let err):
            errorPublisher.send(err)
            return
        case .success(let requestSuccsess):
            request = requestSuccsess
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, _) in
            guard let data = data, let response = response else {
                self.errorPublisher.send(ApiObjectsManagerError.unknownError)
                return
            }
            self.computeResponsePublisherFunc(data: data, response: response, method: .getPaginated)
        }.resume()
    }
    
    func fetchAll() {
        let requestResult = getRequest(method: "GET")
        var request: URLRequest
        switch requestResult {
        case .failure(let err):
            errorPublisher.send(err)
            return
        case .success(let requestSuccsess):
            request = requestSuccsess
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, _) in
            guard let data = data, let response = response else {
                self.errorPublisher.send(ApiObjectsManagerError.unknownError)
                return
            }
            self.computeResponsePublisherFunc(data: data, response: response, method: .getAll)
        }.resume()
    }
    
    func delete(id: T.ID) {
        let requestResult = getRequest(method: "DELETE", urlPostfix: "\(id)/")
        var request: URLRequest
        switch requestResult {
        case .failure(let err):
            errorPublisher.send(err)
            return
        case .success(let requestSuccsess):
            request = requestSuccsess
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, _) in
            guard let data = data, let response = response else {
                self.errorPublisher.send(ApiObjectsManagerError.unknownError)
                return
            }
            self.computeResponsePublisherFunc(data: data, response: response, method: .delete(id: id))
        }.resume()
    }
    
    // MARK: - Requests stuff
    private enum RequestMethod {
        case getConcrete(id: Object.ID)
        case getAll
        case getPaginated
        case delete(id: Object.ID)
        
        var expectedCode: Int {
            switch self {
            case .getConcrete, .getAll, .getPaginated:
                return 200
            case .delete:
                return 204
            }
        }
        
    }
    
    private func getRequest(method: String, urlPostfix: String? = nil) -> Result<URLRequest, ApiObjectsManagerError> {
        guard var url = self.url else {
            return .failure(ApiObjectsManagerError.noHostGiven)
        }
        guard let token = UserData.instance.authToken else {
            return .failure(ApiObjectsManagerError.noTokenGiven)
        }
        if urlPostfix != nil { url.appendPathComponent("\(urlPostfix!)") }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        return .success(request)
    }
    
    private func computeResponsePublisherFunc(data: Data, response: URLResponse, method: RequestMethod){
        // URLResponse -> HTTPURLResponse
        guard let httpResponse = response as? HTTPURLResponse else {
            self.errorPublisher.send(ApiObjectsManagerError.unknownError)
            return
        }
        // Status code cheking
        let code = httpResponse.statusCode
        if code != method.expectedCode {
            guard let jsonDict = (try? JSONSerialization.jsonObject(with: data)) as? [String : Any] else {
                self.errorPublisher.send(ApiObjectsManagerError.codedError(code: code))
                return
            }
            let message = jsonDict.reduce("") { $0 + "\($1.value)" }
            self.errorPublisher.send(ApiObjectsManagerError.codedError(code: code, message: message))
            return
        }
        // Work by method
        let decoder = JSONDecoder()
        switch method {
        case .getConcrete:
            guard let decoded = try? decoder.decode(T.self, from: data) else {
                self.errorPublisher.send(ApiObjectsManagerError.decodeError)
                return
            }
            self.objects.append(decoded)
            return
            
        case .getAll:
            guard let decoded = try? decoder.decode([T].self, from: data) else {
                self.errorPublisher.send(ApiObjectsManagerError.decodeError)
                return
            }
            self.objects = decoded
            return
            
        case .getPaginated:
            guard let decoded = try? decoder.decode([T].self, from: data) else {
                self.errorPublisher.send(ApiObjectsManagerError.decodeError)
                return
            }
            for obj in decoded {
                self.add(obj)
            }
            return
            
        case .delete(let id):
            self.clear(id: id)
            return
        }
    }
    
}
