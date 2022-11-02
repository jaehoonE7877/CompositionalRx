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
    //input : textfield 3개, tap
    struct Input {
        let nameText: ControlProperty<String>
        let emailText: ControlProperty<String>
        let passwordText: ControlProperty<String>
        let signUpTap: ControlEvent<Void>
    }
    //output: label 3개, tap
    struct Output{
        
        let nameValid: Driver<Bool>
        
        let emailValid: Driver<Bool>
        
        let passwordValid: Driver<Bool>
        
        let signUpTap: ControlEvent<Void>
    }
    
    func transform(input: Input) -> Output {
        
        let nameValid = input.nameText
            .map{ $0.count >= 2 }
            .asDriver(onErrorJustReturn: false)
        
        let emailValid = input.emailText
            .map { text in
                self.validateEmail(text)
            }
            .asDriver(onErrorJustReturn: false)
        
        let passwordValid = input.passwordText
            .map{ $0.count >= 8 }
            .asDriver(onErrorJustReturn: false)
        
        input.nameText
            .bind { value in
                self.userName.accept(value)
            }
            .disposed(by: disposeBag)
        
        input.emailText
            .bind { value in
                self.email.accept(value)
            }
            .disposed(by: disposeBag)
            
        input.passwordText
            .bind { value in
                self.password.accept(value)
            }
            .disposed(by: disposeBag)
        
        return Output(nameValid: nameValid, emailValid: emailValid, passwordValid: passwordValid, signUpTap: input.signUpTap)
    }
    
    
    let userName: BehaviorRelay<String> = BehaviorRelay(value: "")
    let email: BehaviorRelay<String> = BehaviorRelay(value: "")
    let password: BehaviorRelay<String> = BehaviorRelay(value: "")
    
    let isSuccess: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    
    func signUpRequest() {
        
        LoginNetworkService.shared.signUp(userName: userName.value, email: email.value, password: password.value) { result in
              
            switch result {
            case .success(let value):
                if value == "ok"{
                    self.isSuccess.onNext(true)
                } else {
                    print(value)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension SignUpViewModel {
    private func validateEmail(_ text: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: text)
    }
}

