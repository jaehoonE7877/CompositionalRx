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
    func dataTask(_ request: URLRequest, completion: @escaping completion) -> URLSessionDataTask{
        let task = dataTask(with: request, completionHandler: completion)
        
        task.resume()
        return task
    }
    
    static func request<T: Codable>(_ session: URLSession = .shared, request: URLRequest, completion: @escaping (T?, APIError?) -> Void) {
        
        session.dataTask(request) { data, response, error in
            
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
                let result = try JSONDecoder().decode(T.self, from: data)
                completion(result, nil)
            } catch {
                completion(nil, .invalidData)
            }
        }

    }
}

enum APIError: Error {
    case invalidResponse
    case noData
    case failedRequest
    case invalidData
}
