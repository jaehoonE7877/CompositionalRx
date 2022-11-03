//
//  LoginNetworkService.swift
//  CompositionalRx
//
//  Created by Seo Jae Hoon on 2022/11/02.
//

import Foundation

enum HttpMethod {
    static let get = "GET"
    static let post = "POST"
}

final class LoginNetworkService {
    
    static let shared = LoginNetworkService()
    
    private init() { }
    
    private let session = URLSession.shared
    
    func signUp(userName: String, email: String, password: String, completion: @escaping (Result<String, APIError>) -> Void) {
        
        let api = SeSACAPI.signup(userName: userName, email: email, password: password)
        
        guard let url = URL(string: api.urlString) else { return }
        
        var component = URLComponents()
        component.queryItems = api.parameters
        let body = component.query?.data(using: .utf8)
        
        let request = createHttpRequest(of: url, httpMethod: HttpMethod.post, with: api.headers, with: body)
            
        session.dataTask(with: request) { data, response, error in
            
            guard error == nil else {
                completion(.failure(.failedRequest))
                return
            }
            
            guard let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard data != nil else {
                completion(.failure(.noData))
                return
            }
            
            completion(.success("ok"))
            
        }.resume()
    }
    
    func requestAuth<T: Decodable>(type: T.Type = T.self, urlString: String, method: String, headers: [String: String]? = nil, body: [URLQueryItem]? = nil, completion: @escaping (Result<T, APIError>) -> Void) {
        
        guard let url = URL(string: urlString) else { return }
        
        var components = URLComponents()
        components.queryItems = body
        let body = components.query?.data(using: .utf8)
        
        let request = createHttpRequest(of: url, httpMethod: method, with: headers, with: body)
        
        session.dataTask(with: request) { data, response, error in
            
            guard error == nil else {
                completion(.failure(.failedRequest))
                return
            }
            
            guard let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let result = try JSONDecoder().decode(T.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(.invalidData))
            }
        }.resume()
    }
    
    private func createHttpRequest(
        of url: URL,
        httpMethod: String,
        with headers: [String: String]? = nil,
        with body: Data? = nil
    ) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        headers?.forEach({ header in
            request.addValue(header.value, forHTTPHeaderField: header.key)
        })
        if let body = body {
            request.httpBody = body
        }
        
        return request
    }

}

