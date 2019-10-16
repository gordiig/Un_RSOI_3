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
    
    var publisher = PassthroughSubject<Bool, Never>()
    var errorPublisher = PassthroughSubject<ApiObjectsManagerError, Never>()
    
    // MARK: - Methods
    func authenticate(username: String, password: String) {
        let authDict = ["username": username, "password": password]
        guard let encoded = try? JSONSerialization.data(withJSONObject: authDict, options: .prettyPrinted) else {
            errorPublisher.send(.encodeError)
            return
        }
        
        switch getRequest(method: .post, urlPostfix: "token-auth/", body: encoded) {
        case .failure(let err):
            errorPublisher.send(err)
            return
            
        case .success(let request):
            URLSession.shared.dataTask(with: request) { (data, response, _) in
                guard let data = data, let response = response else {
                    self.errorPublisher.send(ApiObjectsManagerError.unknownError)
                    return
                }
                self.computeResponsePublisherFunc(data: data, response: response, type: .auth)
            }.resume()
        }
    }
    
    func register(username: String, password: String) {
        let authDict = ["username": username, "password": password]
        guard let encoded = try? JSONSerialization.data(withJSONObject: authDict, options: .prettyPrinted) else {
            errorPublisher.send(.encodeError)
            return
        }
        
        switch getRequest(method: .post, urlPostfix: "register/", body: encoded) {
        case .failure(let err):
            errorPublisher.send(err)
            return
            
        case .success(let request):
            URLSession.shared.dataTask(with: request) { (data, response, _) in
                guard let data = data, let response = response else {
                    self.errorPublisher.send(ApiObjectsManagerError.unknownError)
                    return
                }
                self.computeResponsePublisherFunc(data: data, response: response, type: .register)
            }.resume()
        }
    }
    
    // MARK: - Some privates
    private enum RequestMethod: String {
        case get = "GET"
        case post = "POST"

    }
    
    private enum RequestType {
        case auth
        case register
        
        var expectedCode: Int {
            switch self {
            case .auth:
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
    
    private func parseError(_ data: Data) -> String {
        guard let jsonDict = (try? JSONSerialization.jsonObject(with: data)) as? [String : Any] else {
            return "No message"
        }
        let message = jsonDict.reduce("") { $0 + "\($1.value)" }
        return message
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
    
    private func computeResponsePublisherFunc(data: Data, response: URLResponse, type: RequestType){
        // URLResponse -> HTTPURLResponse
        guard let httpResponse = response as? HTTPURLResponse else {
            self.errorPublisher.send(ApiObjectsManagerError.unknownError)
            return
        }
        // Status code cheking
        let code = httpResponse.statusCode
        if code != type.expectedCode {
            self.errorPublisher.send(.codedError(code: code, message: parseError(data)))
        }
        // Work by method
        switch type {
        case .auth:
            switch parseToken(data) {
            // If token is ok
            case .success(let token):
                UserData.instance.authToken = token
                self.publisher.send(true)
                return
            case .failure(let err):
                switch err {
                // If no token in incame msg
                case .noTokenGiven:
                    let err = parseError(data)
                    self.errorPublisher.send(.codedError(code: code, message: err))
                    return
                // If other errors
                default:
                    self.errorPublisher.send(err)
                    return
                }
            }
            
        case .register:
            guard let decoded = try? JSONDecoder().decode(User.self, from: data) else {
                self.errorPublisher.send(ApiObjectsManagerError.decodeError)
                return
            }
            User.objects.add(decoded)
            UserData.instance.currentUser = decoded
            self.publisher.send(true)
            return
        }
    }
    
}
