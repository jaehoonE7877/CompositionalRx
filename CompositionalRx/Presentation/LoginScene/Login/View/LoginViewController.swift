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
    private let disposeBag = DisposeBag()
    
    private let viewModel = LoginViewModel()
    
    private lazy var emailTextField: UITextField = UITextField().then {
        $0.font = .systemFont(ofSize: 16)
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.addLeftPadding()
        $0.placeholder = "이메일"
    }
    
    private lazy var emailValidLabel: UILabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12)
        $0.text = "이메일 형식이 올바르지 않습니다"
        $0.textColor = .systemRed
    }
    
    private lazy var passwordTextField: UITextField = UITextField().then {
        $0.font = .systemFont(ofSize: 16)
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.keyboardType = .asciiCapable
        $0.placeholder = "비밀번호"
        $0.addLeftPadding()
    }
    
    private lazy var passwordValidLabel: UILabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12)
        $0.text = "비밀번호 형식이 올바르지 않습니다"
        $0.textColor = .systemRed
    }
    
    private lazy var loginButton: UIButton = UIButton().then {
        $0.setTitle("로그인하기", for: .normal)
        $0.layer.cornerRadius = 8
    }
    
    private lazy var signUpButton: UIButton = UIButton().then {
        $0.setTitle("회원가입", for: .normal)
        $0.backgroundColor = .systemOrange
        $0.layer.cornerRadius = 8
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
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        emailValidLabel.snp.makeConstraints { make in
            make.top.equalTo(self.emailTextField.snp.bottom).offset(20)
            make.width.equalTo(self.emailTextField.snp.width)
            make.centerX.equalToSuperview()
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(self.emailValidLabel.snp.bottom).offset(20)
            make.size.equalTo(self.emailTextField.snp.size)
            make.centerX.equalToSuperview()
        }
        
        passwordValidLabel.snp.makeConstraints { make in
            make.top.equalTo(self.passwordTextField.snp.bottom).offset(20)
            make.width.equalTo(self.passwordTextField.snp.width)
            make.centerX.equalToSuperview()
        }
        
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(self.passwordValidLabel.snp.bottom).offset(20)
            make.size.equalTo(self.emailTextField.snp.size)
            make.centerX.equalToSuperview()
        }
        
        signUpButton.snp.makeConstraints { make in
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
            .disposed(by: disposeBag)
        
        output.passwordValid
            .drive(passwordValidLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        output.loginValid
            .drive { [weak self] valid in
                guard let self = self else { return }
                self.loginButton.isEnabled = valid
                self.loginButton.backgroundColor = valid ? .systemOrange : .systemGray
            }
            .disposed(by: disposeBag)
        
        
        output.loginTap
            .withUnretained(self)
            .subscribe { vc, _ in
                vc.viewModel.loginRequest()
            } onError: { error in
                print("=====\(error)")
            } onCompleted: {
                print("=====completed")
            } onDisposed: {
                print("=====disposed")
            }
            .disposed(by: disposeBag)
        
        output.signUpTap
            .withUnretained(self)
            .bind { vc, _ in
                let signUpVC = SignUpViewController()
                vc.present(signUpVC, animated: true)
                //vc.transitionViewController(viewController: signUpVC, transitionStyle: .present)
            }
            .disposed(by: disposeBag)
        
        viewModel.loginSuccess
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .subscribe { (vc, value) in
                let searchVC = SearchViewController()
                let nav = UINavigationController(rootViewController: searchVC)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
            } onError: { error in
                print("========\(error)")
            } onCompleted: {
                print("=====completed")
            } onDisposed: {
                print("=====disposed")
            }
            .disposed(by: disposeBag)

    }
}
