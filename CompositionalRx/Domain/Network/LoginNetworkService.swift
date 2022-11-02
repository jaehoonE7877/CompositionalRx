//
//  LoginNetworkService.swift
//  CompositionalRx
//
//  Created by Seo Jae Hoon on 2022/11/02.
//

import Foundation

final class LoginNetworkService {
    
    static let shared = LoginNetworkService()
    
    private init() { }
    
    private enum HttpMethod {
        static let get = "GET"
        static let post = "POST"
    }
    
    func signUp(userName: String, email: String, password: String, completion: @escaping (Result<String, APIError>) -> Void) {
        
        let api = SeSACAPI.signup(userName: userName, email: email, password: password)
        
        //let urlComponents = URLComponents(string: api.urlString)
        let url = URL(string: api.urlString)
        
        var component = URLComponents()
        component.queryItems = [
            URLQueryItem(name: "userName", value: userName),
            URLQueryItem(name: "email", value: email),
            URLQueryItem(name: "password", value: password),
            URLQueryItem(name: "Content-Type", value: "application/x-www-form-urlencoded")
        ]
        
        var request = URLRequest(url: url!)
        //httpMethod
        request.httpMethod = "POST"
        //body
        request.httpBody = component.query?.data(using: .utf8)
        //header
        request.allHTTPHeaderFields = api.headers
                
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard error == nil else {
                return completion(.failure(.failedRequest))
                
            }
            
            guard let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode else {
                return completion(.failure(.invalidResponse))
            }
            
            guard data != nil else {
                return completion(.failure(.noData))
            }
            
            completion(.success("ok"))
            
        }.resume()
    }
    
    func login(email: String, password: String, completion: @escaping (Result<Login, APIError>) -> Void) {
        
        let api = SeSACAPI.login(email: email, password: password)
        
        let urlComponents = URLComponents(string: api.urlString)
        guard let url = urlComponents?.url else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = HttpMethod.post
        let param = "email=\(email)&password=\(password)"
        request.httpBody = param.data(using: .utf8)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(request) { data, response, error in
            
            guard error == nil else {
                return completion(.failure(.failedRequest))
            }
            
            guard let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode else {
                return completion(.failure(.invalidResponse))
            }
            
            guard let data = data else {
                return completion(.failure(.noData))
            }
            
            guard let result = try? JSONDecoder().decode(Login.self, from: data) else { return }
            //completion(result)
            
        }
    }
    
    func profile(completion: @escaping (UserProfile?, APIError?)-> Void) {
        
        let api = SeSACAPI.profile
        
        let urlComponents = URLComponents(string: api.urlString)
        guard let url = urlComponents?.url else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = HttpMethod.get
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(UserDefaults.standard.string(forKey: "token")!)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(request) { data, response, error in
            
            guard error == nil else {
                completion(nil, .failedRequest)
                return
            }
            
            guard let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode else {
                completion(nil,.invalidResponse)
                return
            }
            
            guard let data = data else {
                completion(nil, .noData)
                return
            }
            
            do {
                let result = try JSONDecoder().decode(UserProfile.self, from: data)
                completion(result, nil)
            } catch {
                completion(nil, .invalidData)
            }
        }
    }
}
