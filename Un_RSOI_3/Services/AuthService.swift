//
//  AuthService.swift
//  Un_RSOI_3
//
//  Created by Dmitry Gorin on 16.10.2019.
//  Copyright © 2019 gordiig. All rights reserved.
//

import Foundation
import Combine


class AuthService {
    // MARK: - Singletone work
    private static var _instance: AuthService?
    class var instance: AuthService {
        if _instance == nil { _instance = AuthService() }
        return _instance!
    }
    
    private init() { }
    
    // MARK: - Variables
    var url: URL? {
        guard let host = UserData.instance.selectedHost else { return nil }
        return URL(string: "http://\(host):8000/api/")!
    }
    
    // MARK: - Methods
    func authenticate(username: String, password: String) -> AnyPublisher<String, ApiObjectsManagerError> {
        let authDict = ["username": username, "password": password]
        guard let encoded = try? JSONSerialization.data(withJSONObject: authDict, options: .prettyPrinted) else {
            return Fail<String, ApiObjectsManagerError>(error: .encodeError).eraseToAnyPublisher()
        }
        var request: URLRequest
        switch getRequest(method: .post, urlPostfix: "token-auth/", body: encoded) {
        case .failure(let err):
            return Fail<String, ApiObjectsManagerError>(error: err).eraseToAnyPublisher()
        case .success(let incameRequest):
            request = incameRequest
        }
        
        let ans = URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { (data, response) -> String in
                try self.checkForErrors(incameData: data, response: response, method: .auth)
                switch self.parseToken(data) {
                case .failure(let err):
                    throw err
                case .success(let token):
                    return token
                }
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
    
    func register(username: String, password: String) -> AnyPublisher<User, ApiObjectsManagerError> {
        let authDict = ["username": username, "password": password]
        guard let encoded = try? JSONSerialization.data(withJSONObject: authDict, options: .prettyPrinted) else {
            return Fail<User, ApiObjectsManagerError>(error: .encodeError).eraseToAnyPublisher()
        }
        var request: URLRequest
        switch getRequest(method: .post, urlPostfix: "register/", body: encoded) {
        case .failure(let err):
            return Fail<User, ApiObjectsManagerError>(error: err).eraseToAnyPublisher()
        case .success(let incameRequest):
            request = incameRequest
        }
        
        let ans = URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { (data, response) -> Data in
                try self.checkForErrors(incameData: data, response: response, method: .register)
                return data
            }
            .decode(type: User.self, decoder: JSONDecoder())
            .mapError { (err) -> ApiObjectsManagerError in
                guard let apiErr = err as? ApiObjectsManagerError else {
                    return .decodeError
                }
                return apiErr
            }
            .eraseToAnyPublisher()
        
        return ans
    }
    
    func getUserInfo(token: String) -> AnyPublisher<User, ApiObjectsManagerError> {
        var request: URLRequest
        switch getRequest(method: .get, urlPostfix: "user-info/") {
        case .failure(let err):
            return Fail<User, ApiObjectsManagerError>(error: err).eraseToAnyPublisher()
        case .success(let incameRequest):
            request = incameRequest
        }
        
        let ans = URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { (data, response) -> Data in
                try self.checkForErrors(incameData: data, response: response, method: .userData)
                return data
            }
            .decode(type: User.self, decoder: JSONDecoder())
            .mapError { (err) -> ApiObjectsManagerError in
                guard let apiErr = err as? ApiObjectsManagerError else {
                    return .decodeError
                }
                return apiErr
            }
            .eraseToAnyPublisher()
        return ans
    }
    
    // MARK: - Some privates
    private enum RequestMethod: String {
        case get = "GET"
        case post = "POST"

    }
    
    private enum RequestType {
        case auth
        case register
        case userData
        
        var expectedCode: Int {
            switch self {
            case .auth, .userData:
                return 200
            case .register:
                return 201
            }
        }
    }
    
    private func getRequest(method: RequestMethod, urlPostfix: String, body: Data? = nil, withToken: Bool = false) -> Result<URLRequest, ApiObjectsManagerError> {
        guard var url = self.url else {
            return .failure(ApiObjectsManagerError.noHostGiven)
        }
        url.appendPathComponent(urlPostfix)
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if body != nil {
            request.httpBody = body!
        }
        if withToken {
            guard let token = UserData.instance.authToken else {
                return .failure(ApiObjectsManagerError.noTokenGiven)
            }
            request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }
        return .success(request)
    }
    
    private func checkForErrors(incameData data: Data, response: URLResponse, method: RequestType) throws {
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
    
    private func parseToken(_ data: Data) -> Result<String, ApiObjectsManagerError> {
        guard let jsonDict = (try? JSONSerialization.jsonObject(with: data)) as? [String : Any] else {
            return .failure(.decodeError)
        }
        if !jsonDict.keys.contains("token") {
            return .failure(.noTokenGiven)
        }
        return .success(jsonDict["token"] as! String)
    }

}
