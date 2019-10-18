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
protocol ApiObject: Codable, Identifiable, ObservableObject {
    associatedtype Manager: ApiObjectsManager
    
    var isComplete: Bool { get }
    static var objects: Manager { get }
    
}


// MARK: - Manager
protocol ApiObjectsManager: ObservableObject {
    associatedtype Object: ApiObject
    
    // MARK: - All-local calls
    
    /// Publisher for values update
    var updatePublisher: PassthroughSubject<Void, Never> { get }
    
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
    func delete(id: Object.ID) -> AnyPublisher<Void, ApiObjectsManagerError>
    
    
    /// Fetches object with given ID
    /// - Parameter id: ID of the object to be fetched
    func fetch(id: Object.ID) -> AnyPublisher<Object, ApiObjectsManagerError>
    
    /// Fetches objects with limit-offset pagination
    /// - Parameter limit: Limit for pagination
    /// - Parameter offset: Offset for pagination
    func fetch(limit: Int, offset: Int) -> AnyPublisher<[Object], ApiObjectsManagerError>
    
    /// Fetches all objects from server
    func fetchAll() -> AnyPublisher<[Object], ApiObjectsManagerError>

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
class BaseApiObjectsManager<T: ApiObject>: ApiObjectsManager, ObservableObject {
    // MARK: - Variables
    @Published var objects = [T]() {
        didSet {
            updatePublisher.send()
        }
    }
    
    var url: URL? {
        guard let host = UserData.instance.selectedHost else { return nil }
        return URL(string: "http://\(host):8000/api/")
    }
    
    // MARK: - Locals imlementation
    var updatePublisher = PassthroughSubject<Void, Never>()
    
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
    func fetch(id: T.ID) -> AnyPublisher<T, ApiObjectsManagerError> {
        let requestResult = getRequest(method: "GET", urlPostfix: "\(id)/")
        var request: URLRequest
        switch requestResult {
        case .failure(let err):
            return Fail(outputType: T.self, failure: err).eraseToAnyPublisher()
        case .success(let requestSuccsess):
            request = requestSuccsess
        }
        
        let ans = URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { (data, response) -> Data in
                try self.checkForErrors(incameData: data, response: response, method: .getConcrete(id: id))
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError({ (err) -> ApiObjectsManagerError in
                guard let apiErr = err as? ApiObjectsManagerError else {
                    return .decodeError
                }
                return apiErr
            })
            .eraseToAnyPublisher()
        return ans
    }
    
    func fetch(limit: Int, offset: Int) -> AnyPublisher<[T], ApiObjectsManagerError> {
        let requestResult = getRequest(method: "GET", urlPostfix: "?limit=\(limit)&offset=\(offset)")
        var request: URLRequest
        switch requestResult {
        case .failure(let err):
            return Fail(outputType: [T].self, failure: err).eraseToAnyPublisher()
        case .success(let requestSuccsess):
            request = requestSuccsess
        }
        
        let ans = URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { (data, response) -> Data in
                try self.checkForErrors(incameData: data, response: response, method: .getPaginated)
                return data
            }
            .decode(type: [T].self, decoder: JSONDecoder())
            .mapError({ (err) -> ApiObjectsManagerError in
                guard let apiErr = err as? ApiObjectsManagerError else {
                    return .decodeError
                }
                return apiErr
            })
            .eraseToAnyPublisher()
        return ans
    }
    
    func fetchAll() -> AnyPublisher<[T], ApiObjectsManagerError> {
        let requestResult = getRequest(method: "GET")
        var request: URLRequest
        switch requestResult {
        case .failure(let err):
            return Fail(outputType: [T].self, failure: err).eraseToAnyPublisher()
        case .success(let requestSuccsess):
            request = requestSuccsess
        }
        
        let ans = URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { (data, response) -> Data in
                try self.checkForErrors(incameData: data, response: response, method: .getAll)
                return data
            }
            .decode(type: [T].self, decoder: JSONDecoder())
            .mapError({ (err) -> ApiObjectsManagerError in
                guard let apiErr = err as? ApiObjectsManagerError else {
                    return .decodeError
                }
                return apiErr
            })
            .eraseToAnyPublisher()
        return ans
    }
    
    func delete(id: T.ID) -> AnyPublisher<Void, ApiObjectsManagerError> {
        let requestResult = getRequest(method: "DELETE", urlPostfix: "\(id)/")
        var request: URLRequest
        switch requestResult {
        case .failure(let err):
            return Fail(outputType: Void.self, failure: err).eraseToAnyPublisher()
        case .success(let requestSuccsess):
            request = requestSuccsess
        }
        
        let ans = URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { (data, response) -> Void in
                try self.checkForErrors(incameData: data, response: response, method: .delete(id: id))
                return
            }
            .mapError { (err) -> ApiObjectsManagerError in
                guard let apiErr = err as? ApiObjectsManagerError else {
                    return .unknownError
                }
                return apiErr
            }
            .eraseToAnyPublisher()
        return ans
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
    
    private func checkForErrors(incameData data: Data, response: URLResponse, method: RequestMethod) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ApiObjectsManagerError.unknownError
        }
        let code = httpResponse.statusCode
        if code != method.expectedCode {
            throw self.parseIncameError(code: code, incameData: data)
        }
    }
    
    private func parseIncameError(code: Int, incameData data: Data) -> ApiObjectsManagerError {
        guard let jsonDict = (try? JSONSerialization.jsonObject(with: data)) as? [String : Any] else {
            return ApiObjectsManagerError.codedError(code: code)
        }
        let message = jsonDict.reduce("") { $0 + "\($1.value)" }
        return ApiObjectsManagerError.codedError(code: code, message: message)
    }
    
}
