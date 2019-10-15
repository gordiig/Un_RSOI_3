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
    case decodeError
    case unknownError
    case codedError(code: Int, message: String = "No message")
    
}

// MARK: - BaseManager class
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
    
    func clear() {
        objects = []
    }
    func clear(id: T.ID) {
        objects.removeAll { $0.id == id }
    }
    
    // MARK: - Semi-local implementation
    func fetch(id: T.ID) {
        guard let url = self.url?.appendingPathComponent("\(id)/") else {
            errorPublisher.send(ApiObjectsManagerError.noHostGiven)
        }
        
        let _ = URLSession.shared.dataTask(with: url) { (data, response, _) in
            guard let data = data, let response = response else {
                self.errorPublisher.send(ApiObjectsManagerError.unknownError)
            }
            self.computeResponsePublisherFunc(data: data, response: response, method: .getConcrete(id: id))
        }
    }
    
    func fetch(limit: Int, offset: Int) {
        guard let url = self.url?.appendingPathComponent("?limit=\(limit)&offset=\(offset)") else {
            errorPublisher.send(ApiObjectsManagerError.noHostGiven)
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, _) in
            guard let data = data, let response = response else {
                self.errorPublisher.send(ApiObjectsManagerError.unknownError)
            }
            self.computeResponsePublisherFunc(data: data, response: response, method: .getMany)
        }.resume()
    }
    
    func fetchAll() {
        guard let url = self.url else {
            errorPublisher.send(ApiObjectsManagerError.noHostGiven)
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, _) in
            guard let data = data, let response = response else {
                self.errorPublisher.send(ApiObjectsManagerError.unknownError)
            }
            self.computeResponsePublisherFunc(data: data, response: response, method: .getMany)
        }.resume()
    }
    
    func delete(id: T.ID) {
        guard let url = self.url else {
            errorPublisher.send(ApiObjectsManagerError.noHostGiven)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (data, response, _) in
            guard let data = data, let response = response else {
                self.errorPublisher.send(ApiObjectsManagerError.unknownError)
            }
            self.computeResponsePublisherFunc(data: data, response: response, method: .delete(id: id))
        }.resume()
    }
    
    // MARK: - Requests stuff
    private enum RequestMethod {
        case getConcrete(id: Object.ID)
        case getMany
        case delete(id: Object.ID)
        
        var expectedCode: Int {
            switch self {
            case .getConcrete, .getMany:
                return 200
            case .delete:
                return 204
            }
        }
        
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
            
        case .getMany:
            guard let decoded = try? decoder.decode([T].self, from: data) else {
                self.errorPublisher.send(ApiObjectsManagerError.decodeError)
                return
            }
            self.objects.append(contentsOf: decoded)
            return
            
        case .delete(let id):
            self.clear(id: id)
            return
        }
    }
    
}
