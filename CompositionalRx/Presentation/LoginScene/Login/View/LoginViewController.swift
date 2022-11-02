//
//  LoginViewController.swift
//  CompositionalRx
//
//  Created by Seo Jae Hoon on 2022/11/02.
//

import UIKit
import RxCocoa
import RxSwift
final class LoginViewController: BaseViewController {
    
    //MARK: Property
    private let disposebag = DisposeBag()
    
    private let viewModel = LoginViewModel()
    
    private lazy var emailTextField: UITextField = UITextField().then {
        $0.font = .systemFont(ofSize: 14)
        $0.layer.cornerRadius = 5
        $0.layer.borderWidth = 1
    }
    
    private lazy var emailValidLabel: UILabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12)
        $0.text = "이메일 형식이 올바르지 않습니다"
        $0.textColor = .systemRed
    }
    
    private lazy var passwordTextField: UITextField = UITextField().then {
        $0.font = .systemFont(ofSize: 14)
        $0.layer.cornerRadius = 5
        $0.layer.borderWidth = 1
        $0.keyboardType = .asciiCapable
    }
    
    private lazy var passwordValidLabel: UILabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12)
        $0.text = "비밀번호 형식이 올바르지 않습니다"
        $0.textColor = .systemRed
    }
    
    private lazy var loginButton: UIButton = UIButton().then {
        $0.setTitle("로그인하기", for: .normal)
        $0.layer.cornerRadius = 5
    }
    
    private lazy var signUpButton: UIButton = UIButton().then {
        $0.setTitle("회원가입", for: .normal)
        $0.backgroundColor = .systemOrange
        $0.layer.cornerRadius = 5
    }
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
    
    override func configure() {
        [emailTextField, emailValidLabel, passwordTextField, passwordValidLabel, loginButton, signUpButton].forEach { self.view.addSubview($0)}
    }
    
    override func setConstraints() {
        self.emailTextField.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        self.emailValidLabel.snp.makeConstraints { make in
            make.top.equalTo(self.emailTextField.snp.bottom).offset(20)
            make.width.equalTo(self.emailTextField.snp.width)
            make.centerX.equalToSuperview()
        }
        
        self.passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(self.emailValidLabel.snp.bottom).offset(20)
            make.size.equalTo(self.emailValidLabel.snp.size)
            make.centerX.equalToSuperview()
        }
        
        self.passwordValidLabel.snp.makeConstraints { make in
            make.top.equalTo(self.passwordTextField.snp.bottom).offset(20)
            make.width.equalTo(self.passwordTextField.snp.width)
            make.centerX.equalToSuperview()
        }
        
        self.loginButton.snp.makeConstraints { make in
            make.top.equalTo(self.passwordValidLabel.snp.bottom).offset(20)
            make.size.equalTo(self.passwordValidLabel.snp.size)
            make.centerX.equalToSuperview()
        }
        
        self.signUpButton.snp.makeConstraints { make in
            make.top.equalTo(self.loginButton.snp.bottom).offset(20)
            make.size.equalTo(self.loginButton.snp.size)
            make.centerX.equalToSuperview()
        }
    }
    
    override func setBinding() {
        
        let input = LoginViewModel.Input(
            emailText: emailTextField.rx.text.orEmpty,
            passwordText: passwordTextField.rx.text.orEmpty,
            loginTap: loginButton.rx.tap,
            signUpTap: signUpButton.rx.tap
        )
        let output = viewModel.transform(input: input)
        
        output.emailValid
            .drive(passwordTextField.rx.isEnabled, emailValidLabel.rx.isHidden)
            .disposed(by: disposebag)
        
        output.passwordValid
            .drive(loginButton.rx.isEnabled, passwordValidLabel.rx.isHidden)
            .disposed(by: disposebag)
        
        output.passwordValid
            .drive { [weak self] value in
                guard let self = self else { return }
                let color: UIColor = value ? .systemOrange : .systemGray2
                self.loginButton.backgroundColor = color
            }
            .disposed(by: disposebag)
        
        output.loginTap
            .withUnretained(self)
            .subscribe { (vc, _) in
                vc.viewModel.loginRequest()
            } onError: { error in
                print("=====\(error)")
            } onCompleted: {
                print("=====completed")
            } onDisposed: {
                print("=====disposed")
            }
            .disposed(by: disposebag)
        
        output.signUpTap
            .withUnretained(self)
            .bind { (vc, _) in
                let signUpVC = SignUpViewController()
                vc.present(signUpVC, animated: true)
            }
            .disposed(by: disposebag)
        
//        viewModel.loginSuccess
//            .withUnretained(self)
//            .observe(on: MainScheduler.instance)
//            .subscribe { <#(LoginViewController, Bool)#> in
//                <#code#>
//            } onError: { <#Error#> in
//                <#code#>
//            } onCompleted: {
//                <#code#>
//            } onDisposed: {
//                <#code#>
//            }

    }
}
