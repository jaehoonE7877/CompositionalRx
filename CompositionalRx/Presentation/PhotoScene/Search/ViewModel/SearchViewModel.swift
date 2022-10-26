//
//  SearchViewModel.swift
//  CompositionalRx
//
//  Created by Seo Jae Hoon on 2022/10/26.
//

import Foundation
import RxSwift
import RxRelay

enum SearchError: Error {
    case noPhoto
    case serverError
}

final class SearchViewModel {
    
    var photoList = PublishSubject<SearchPhoto>()
    
    func requestSearchPhoto(query: String) {
        
        NetworkService.searchPhoto(query: query) { [weak self] photo, statusCode, error in
            
            guard let statusCode , statusCode == 200 else {
                self?.photoList.onError(SearchError.serverError)
                return
            }
            
            guard let photo else {
                self?.photoList.onError(SearchError.noPhoto)
                return
            }
            
            self?.photoList.onNext(photo)
        }
    }
    
}
