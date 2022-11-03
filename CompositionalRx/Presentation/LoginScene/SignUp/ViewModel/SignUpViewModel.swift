//
//  SignUpViewModel.swift
//  CompositionalRx
//
//  Created by Seo Jae Hoon on 2022/11/02.
//

import Foundation
import RxSwift
import RxCocoa


final class SignUpViewModel: ViewModelType {
    
    private let disposeBag = DisposeBag()
    
    struct Input {
        let nameText: ControlProperty<String>
        let emailText: ControlProperty<String>
        let passwordText: ControlProperty<String>
        let signUpTap: ControlEvent<Void>
    }
    
    struct Output{
        let nameValid: Driver<Bool>
        let emailValid: Driver<Bool>
        let passwordValid: Driver<Bool>
        var signUpValid: Driver<Bool>
        let signUpTap: ControlEvent<Void>
    }
    
    func transform(input: Input) -> Output {
        
        let nameValid = input.nameText
            .map{ $0.count >= 2 }
            .asDriver(onErrorJustReturn: false)
        
        let emailValid = input.emailText
            .withUnretained(self)
            .map { vm, text in
                vm.validateEmail(text)
            }
            .asDriver(onErrorJustReturn: false)
        
        let passwordValid = input.passwordText
            .map{ $0.count >= 8 }
            .asDriver(onErrorJustReturn: false)
        
        let signUpValid = Driver.combineLatest(nameValid, emailValid, passwordValid){ name, email, password in
            return name && email && password
        }
        
        input.nameText
            .withUnretained(self)
            .bind { vm, value in
                vm.userName.accept(value)
            }
            .disposed(by: disposeBag)
        
        input.emailText
            .withUnretained(self)
            .bind { vm, value in
                vm.email.accept(value)
            }
            .disposed(by: disposeBag)
        
        input.passwordText
            .withUnretained(self)
            .bind { vm, value in
                vm.password.accept(value)
            }
            .disposed(by: disposeBag)
        
        return Output(nameValid: nameValid, emailValid: emailValid, passwordValid: passwordValid, signUpValid: signUpValid, signUpTap: input.signUpTap)
    }
    
    
    let userName: BehaviorRelay<String> = BehaviorRelay(value: "")
    let email: BehaviorRelay<String> = BehaviorRelay(value: "")
    let password: BehaviorRelay<String> = BehaviorRelay(value: "")
    
    let isSuccess: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    let isSame: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    
    func signUpRequest() {
        
        LoginNetworkService.shared.signUp(userName: userName.value, email: email.value, password: password.value) { result in
            
            switch result {
            case .success(let value):
                if value == "ok"{
                    self.isSuccess.onNext(true)
                } else {
                    
                }
            case .failure(let error):
                //error처리
                print(error)
            }
        }
    }
}
