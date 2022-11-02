//
//  APIService.swift
//  CompositionalRx
//
//  Created by Seo Jae Hoon on 2022/10/26.
//

import Foundation

import Alamofire
import RxSwift
import RxRelay

final class PhotoNetworkService {
    
    private init() { }
    
    typealias completion = (SearchPhoto?, Int?, Error?) -> Void
    
    static func searchPhoto(query: String, completion: @escaping completion) {
        
        guard let url = URL(string: EndPoint.search(query: query).getURL) else { return }
        let header: HTTPHeaders = ["Authorization": APIKey.authorization]
        
        AF.request(url, method: .get, headers: header).responseDecodable(of: SearchPhoto.self) { response in
            
            let statusCode = response.response?.statusCode // 상태 코드 조건문 처리 해보기
            
            switch response.result {
                
            case .success(let value):
                //print(value)
                
                completion(value, statusCode, nil)
                
            case .failure(let error):
                print(error)
                
                completion(nil, statusCode, error)
            }
        }
    }
}
