//
//  ApiCaller.swift
//  Un_RSOI_3
//
//  Created by Dmitry Gorin on 02.10.2019.
//  Copyright © 2019 gordiig. All rights reserved.
//

import Foundation
import func Alamofire.request
import struct Alamofire.DataResponse
import struct Alamofire.JSONEncoding


// MARK: - Errors
enum ApiCallerError: Error {
    case noTokenError
    case noHostGiven
    case wrongTokenError
    case cantDecode
    case cantEncode
    case alamofireError
    case unknownError
    case incameError(code: Int, text: String)
}


// MARK: - Protocol
protocol ApiCaller {
    associatedtype Object: ApiObject
    
    var baseUrlStr: String? { get }
    var baseUrl: URL? { get }
    
    var tokenStr: String? { get }
    
    func getAll(_ completion: @escaping (Result<[Object], ApiCallerError>) -> Void)
    func getPaginated(paginationSuffix: String, _ completion: @escaping (Result<[Object], ApiCallerError>) -> Void)
    func getPaginated(limit: Int, offset: Int, _ completion: @escaping (Result<[Object], ApiCallerError>) -> Void)
    
    func get(id: String, _ completion: @escaping (Result<Object, ApiCallerError>) -> Void)
    
    func post(_ object: Object, _ completion: @escaping (Result<Object, ApiCallerError>) -> Void)
    
    func patch(_ object: Object, newObject: Object, _ completion: @escaping (Result<Object, ApiCallerError>) -> Void)
    
    func delete(_ object: Object, _ completion: @escaping (Result<Object?, ApiCallerError>) -> Void)

}


// MARK: - Default implementation
class BaseApiCaller<T: ApiObject>: ApiCaller {
    
    fileprivate init() {
        
    }
    
    // MARK: - Urls
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
    
    // MARK: - Token
    var tokenStr: String? {
        guard let token = UserData.instance.authToken else {
            return nil
        }
        return "Token \(token)"
    }
    
    var tokenHeader: [String : String]? {
        guard let token = tokenStr else {
            return nil
        }
        return ["Authorization" : token]
    }
    
    // MARK: - Fileprivate funcs
    fileprivate func decodeResponse<U: Decodable>(response: DataResponse<Any>, neededCode: Int, needToDecodeResult: Bool = true) -> Result<U?, ApiCallerError> {
        switch response.result {
        case .success(let json):
            let jsonData = json as! Data
            let decoder = JSONDecoder()
            // Получаем код возврата
            guard let code = response.response?.statusCode else {
                return .failure(.unknownError)
            }
            // Если ошибка авторизации
            if code == 401 || code == 403 {
                return .failure(.wrongTokenError)
            }
            // Если пришел неправидьный код
            if code != neededCode {
                guard let error = try? decoder.decode(ApiError.self, from: jsonData) else {
                    return .failure(.cantDecode)
                }
                return .failure(.incameError(code: code, text: error.text))
            }
            // Все ОК, декодируем объект
            if needToDecodeResult {
                guard let object = try? decoder.decode(U.self, from: jsonData) else {
                    return .failure(.cantDecode)
                }
                return .success(object)
            }
            // Если декодировать не надо, но все ок
            return .success(nil)
            
        case .failure:
            return .failure(.alamofireError)
        }
    }
    
    // MARK: - Get lists
    func getAll(_ completion: @escaping (Result<[T], ApiCallerError>) -> Void) {
        guard let tokenHeader = tokenHeader else {
            completion(.failure(.noTokenError))
            return
        }
        guard let url = baseUrlStr else {
            completion(.failure(.noHostGiven))
            return
        }
        request(url, method: .get, headers: tokenHeader).responseJSON { response in
            let result: Result<[T]?, ApiCallerError> = self.decodeResponse(response: response, neededCode: 200)
            switch result {
            case .success(let objects):
                completion(.success(objects!))
            case .failure(let err):
                completion(.failure(err))
            }
        }
    }
    
    func getPaginated(paginationSuffix: String, _ completion: @escaping (Result<[T], ApiCallerError>) -> Void) {
        guard let tokenHeader = tokenHeader else {
            completion(.failure(.noTokenError))
            return
        }
        guard let url = baseUrlStr else {
            completion(.failure(.noHostGiven))
            return
        }
        request(url + paginationSuffix, method: .get, headers: tokenHeader).responseJSON { response in
            let result: Result<PaginatedApiObject<T>?, ApiCallerError> = self.decodeResponse(response: response, neededCode: 200)
            switch result {
            case .success(let object):
                completion(.success(object!.results))
            case .failure(let err):
                completion(.failure(err))
            }
        }
    }
    
    func getPaginated(limit: Int, offset: Int, _ completion: @escaping (Result<[T], ApiCallerError>) -> Void) {
        getPaginated(paginationSuffix: "?limit=\(limit)&offset=\(offset)", completion)
    }
    
    // MARK: - Get by id
    func get(id: String, _ completion: @escaping (Result<T, ApiCallerError>) -> Void) {
        guard let tokenHeader = tokenHeader else {
            completion(.failure(.noTokenError))
            return
        }
        guard let url = baseUrlStr else {
            completion(.failure(.noHostGiven))
            return
        }
        request(url + id, method: .get, headers: tokenHeader).responseJSON { response in
            let result: Result<T?, ApiCallerError> = self.decodeResponse(response: response, neededCode: 200)
            switch result {
            case .success(let object):
                completion(.success(object!))
            case .failure(let err):
                completion(.failure(err))
            }
        }
    }
    
    // MARK: - Post
    func post(_ object: T, _ completion: @escaping (Result<T, ApiCallerError>) -> Void) {
        guard let tokenHeader = tokenHeader else {
            completion(.failure(.noTokenError))
            return
        }
        guard let url = baseUrlStr else {
            completion(.failure(.noHostGiven))
            return
        }
        let encoder = JSONEncoder()
        guard let encodedData = try? encoder.encode(object) else {
            completion(.failure(.cantEncode))
            return
        }
        let params = try! JSONSerialization.jsonObject(with: encodedData) as! [String : Any]
        request(url, method: .post, parameters: params, encoding: JSONEncoding(), headers: tokenHeader).responseJSON { response in
            let result: Result<T?, ApiCallerError> = self.decodeResponse(response: response, neededCode: 201)
            switch result {
            case .success(let object):
                completion(.success(object!))
            case .failure(let err):
                completion(.failure(err))
            }
        }
    }
    
    // MARK: - Patch
    func patch(_ object: T, newObject: T, _ completion: @escaping (Result<T, ApiCallerError>) -> Void) {
        guard let tokenHeader = tokenHeader else {
            completion(.failure(.noTokenError))
            return
        }
        guard let url = baseUrlStr else {
            completion(.failure(.noHostGiven))
            return
        }
        let encoder = JSONEncoder()
        guard let encodedData = try? encoder.encode(newObject) else {
            completion(.failure(.cantEncode))
            return
        }
        let params = try! JSONSerialization.jsonObject(with: encodedData) as! [String : Any]
        request(url + "\(object.id)", method: .patch, parameters: params, encoding: JSONEncoding(), headers: tokenHeader).responseJSON { response in
            let result: Result<T?, ApiCallerError> = self.decodeResponse(response: response, neededCode: 202)
            switch result {
            case .success(let object):
                completion(.success(object!))
            case .failure(let err):
                completion(.failure(err))
            }
        }
    }
    
    // MARK: - Delete
    func delete(_ object: T, _ completion: @escaping (Result<T?, ApiCallerError>) -> Void) {
        guard let tokenHeader = tokenHeader else {
            completion(.failure(.noTokenError))
            return
        }
        guard let url = baseUrlStr else {
            completion(.failure(.noHostGiven))
            return
        }
        request(url + "\(object.id)", method: .delete, headers: tokenHeader).responseJSON { response in
            let result: Result<T?, ApiCallerError> = self.decodeResponse(response: response, neededCode: 204)
            switch result {
            case .success(let object):
                completion(.success(object))
            case .failure(let err):
                completion(.failure(err))
            }
        }
    }
    
}


// MARK: - Images API caller
class ImagesApiCaller: BaseApiCaller<Image> {
    private static var _instance: ImagesApiCaller?
    class var instance: ImagesApiCaller {
        if _instance == nil {
            _instance = ImagesApiCaller()
        }
        return _instance!
    }
    
    fileprivate override init() {
        
    }
    
    // MARK: - Overriding baseUrlStr
    override var baseUrlStr: String? {
        guard let base = super.baseUrlStr else {
            return nil
        }
        return base + "images/"
    }
}


// MARK: - Audios API caller
class AudiosApiCaller: BaseApiCaller<Audio> {
    private static var _instance: AudiosApiCaller?
    class var instance: AudiosApiCaller {
        if _instance == nil {
            _instance = AudiosApiCaller()
        }
        return _instance!
    }
    
    fileprivate override init() {
        
    }
    
    // MARK: - Overriding baseUrlStr
    override var baseUrlStr: String? {
        guard let base = super.baseUrlStr else {
            return nil
        }
        return base + "audio/"
    }
}


// MARK: - Messages API caller
class MessagesApiCaller: BaseApiCaller<Message> {
    private static var _instance: MessagesApiCaller?
    class var instance: MessagesApiCaller {
        if _instance == nil {
            _instance = MessagesApiCaller()
        }
        return _instance!
    }
    
    fileprivate override init() {
        
    }
    
    // MARK: - Overriding baseUrlStr
    override var baseUrlStr: String? {
        guard let base = super.baseUrlStr else {
            return nil
        }
        return base + "messages/"
    }
}
