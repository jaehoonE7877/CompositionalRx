//
//  LoginViewModel.swift
//  CompositionalRx
//
//  Created by Seo Jae Hoon on 2022/11/02.
//

import Foundation

import RxCocoa
import RxSwift

final class LoginViewModel: ViewModelType {
    
    private let disposebag = DisposeBag()
    
    struct Input {
        let emailText: ControlProperty<String>
        let passwordText: ControlProperty<String>
        let loginTap: ControlEvent<Void>
        let signUpTap: ControlEvent<Void>
    }
    
    struct Output {
        let emailValid: Driver<Bool>
        let passwordValid: Driver<Bool>
        let loginTap: ControlEvent<Void>
        let signUpTap: ControlEvent<Void>
    }
    
    func transform(input: Input) -> Output {
        
        let emailValid = input.emailText
            .map { text in
                self.validateEmail(text)
            }
            .asDriver(onErrorJustReturn: false)
        
        let passwordValid = input.passwordText
            .map { $0.count >= 8 }
            .asDriver(onErrorJustReturn: false)
        
        input.emailText
            .bind { email in
                self.email.accept(email)
            }
            .disposed(by: disposebag)
        
        input.passwordText
            .bind { password in
                self.password.accept(password)
            }
            .disposed(by: disposebag)
        
        return Output(emailValid: emailValid, passwordValid: passwordValid, loginTap: input.loginTap, signUpTap: input.signUpTap)
    }
    
    let email: BehaviorRelay<String> = BehaviorRelay(value: "")
    let password: BehaviorRelay<String> = BehaviorRelay(value: "")
    
    let loginSuccess: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    
    func loginRequest() {
        
        LoginNetworkService.shared.login(email: email.value, password: password.value) { response in
            
            switch response {
            case .success(let value):
                UserDefaults.standard.set(value.token, forKey: "token")
                self.loginSuccess.onNext(true)
            case .failure(let error):
                print(error)
            }
            
        }
        
    }
}

extension LoginViewModel {
    private func validateEmail(_ text: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: text)
    }
}
