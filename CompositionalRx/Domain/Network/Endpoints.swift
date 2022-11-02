//
//  Endpoints.swift
//  CompositionalRx
//
//  Created by Seo Jae Hoon on 2022/10/26.
//

import Foundation
import Alamofire

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

enum SeSACAPI {
    case signup(userName: String, email: String, password: String)
    case login(email: String, password: String)
    case profile
}

extension SeSACAPI {
    
    var urlString: String {
        switch self {
        case .signup:
            return "http://api.memolease.com/api/v1/users/signup"
        case .login:
            return "http://api.memolease.com/api/v1/users/login"
        case .profile:
            return "http://api.memolease.com/api/v1/users/me"
        }
    }
    
    var headers: [String : String] {
        switch self {
        case .signup, .login:
            return ["Content-Type": "application/x-www-form-urlencoded"]
        case .profile:
            return [
                "Authorization": "Bearer \(UserDefaults.standard.string(forKey: "token")!)",
                "Content-Type": "application/x-www-form-urlencoded"
            ]
        }
    }
    
    var parameters: [String: String] {
        switch self {
        case .signup(let userName, let email,let password):
            return [
                "userName": userName,
                "email": email,
                "password": password
            ]
        case .login(let email, let password):
            return [
                "email": email,
                "password": password
            ]
        default: return ["": ""]
        }
    }
    
}
