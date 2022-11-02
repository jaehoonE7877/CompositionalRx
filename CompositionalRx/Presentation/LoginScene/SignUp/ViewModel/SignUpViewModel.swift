//
//  SignUpViewModel.swift
//  CompositionalRx
//
//  Created by Seo Jae Hoon on 2022/11/02.
//

import Foundation
import RxSwift
import RxCocoa
final class SignUpViewModel {
    
    let name: PublishRelay<String> = PublishRelay<String>()
    let email: PublishRelay<String> = PublishRelay<String>()
    let password: PublishRelay<String> = PublishRelay<String>()
    
    let validation: Observable<Bool> = Observable.of(false)
}
