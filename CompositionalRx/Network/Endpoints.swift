//
//  Endpoints.swift
//  CompositionalRx
//
//  Created by Seo Jae Hoon on 2022/10/26.
//

import Foundation

enum EndPoint {
    case search(query: String)
    case list
    case random
}

extension EndPoint {
    
    static let baseURL = "https://api.unsplash.com"
    
    var getURL: String {
        
        switch self {
        case .search(let query):
            return "\(EndPoint.baseURL)/search/photos?query=\(query)"
        case .list:
            return "\(EndPoint.baseURL)/photos?query="
        case .random:
            return "\(EndPoint.baseURL)/photos/random?query="
        }
    }
    
}
