//
//  URLSession+.swift
//  CompositionalRx
//
//  Created by Seo Jae Hoon on 2022/11/02.
//

import Foundation

extension URLSession {
    
    typealias completion = (Data?, URLResponse?, Error?)-> Void
    
    @discardableResult
    private func dataTask(_ request: URLRequest, completion: @escaping completion) -> URLSessionDataTask{
        let task = dataTask(with: request, completionHandler: completion)
        
        task.resume()
        return task
    }
    
    static func request<T: Codable>(_ session: URLSession = .shared, request: URLRequest, completion: @escaping (Result<T, APIError>) -> Void) {
        
        session.dataTask(request) { data, response, error in
            
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
        }
    }
}
