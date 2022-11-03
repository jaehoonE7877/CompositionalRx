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
        let loginValid: Driver<Bool>
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
        
        let loginValid = Driver.combineLatest(emailValid, passwordValid) { email, password in
            return email && password
        }
        
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
        
        return Output(emailValid: emailValid, passwordValid: passwordValid, loginValid: loginValid, loginTap: input.loginTap, signUpTap: input.signUpTap)
    }
    
    let email: BehaviorRelay<String> = BehaviorRelay(value: "")
    let password: BehaviorRelay<String> = BehaviorRelay(value: "")
    
    let loginSuccess: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    
    func loginRequest() {
        
        let api = SeSACAPI.login(email: email.value, password: password.value)
        
        LoginNetworkService.shared.requestAuth(type: Login.self, urlString: api.urlString, method: HttpMethod.post, headers: api.headers, body: api.parameters) { response in
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
