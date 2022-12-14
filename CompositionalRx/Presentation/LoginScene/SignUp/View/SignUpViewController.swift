//
//  SignUpViewController.swift
//  CompositionalRx
//
//  Created by Seo Jae Hoon on 2022/11/02.
//

import UIKit
import RxCocoa
import RxSwift

final class SignUpViewController: BaseViewController, Alertable {
    
    // 고려할 점: 회원가입 시 비밀번호는 재입력을 하는 부분도 있다.
    //MARK: Property
    private let disposeBag = DisposeBag()
    
    private let viewModel = SignUpViewModel()
    
    private lazy var nameTextField: UITextField = UITextField().then {
        $0.font = .systemFont(ofSize: 16)
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.placeholder = "닉네임"
        $0.addLeftPadding()
        $0.becomeFirstResponder()
    }
    
    private lazy var nameValidLabel: UILabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12)
        $0.text = "이름은 최소 2글자 이상 작성해주세요"
        $0.textColor = .systemRed
    }
    
    private lazy var emailTextField: UITextField = UITextField().then {
        $0.font = .systemFont(ofSize: 16)
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.placeholder = "이메일"
        $0.addLeftPadding()
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
        $0.text = "8자리 이상 입력해 주세요."
        $0.textColor = .systemRed
    }
    
    private lazy var signupButton: UIButton = UIButton().then {
        $0.setTitle("회원가입", for: .normal)
        $0.backgroundColor = .systemOrange
        $0.layer.cornerRadius = 8
    }
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
    
    //MARK: COnfigure UI
    override func configure() {
        [nameTextField, nameValidLabel, emailTextField, emailValidLabel, passwordTextField, passwordValidLabel, signupButton].forEach{ self.view.addSubview($0)}
    }
    
    override func setConstraints() {
        
        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        nameValidLabel.snp.makeConstraints { make in
            make.top.equalTo(self.nameTextField.snp.bottom).offset(20)
            make.width.equalTo(self.nameTextField.snp.width)
            make.centerX.equalToSuperview()
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(self.nameValidLabel.snp.bottom).offset(20)
            make.size.equalTo(self.nameTextField.snp.size)
            make.centerX.equalToSuperview()
        }
        
        emailValidLabel.snp.makeConstraints { make in
            make.top.equalTo(self.emailTextField.snp.bottom).offset(20)
            make.width.equalTo(self.nameTextField.snp.width)
            make.centerX.equalToSuperview()
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(self.emailValidLabel.snp.bottom).offset(20)
            make.size.equalTo(self.nameTextField.snp.size)
            make.centerX.equalToSuperview()
        }
        
        passwordValidLabel.snp.makeConstraints { make in
            make.top.equalTo(self.passwordTextField.snp.bottom).offset(20)
            make.width.equalTo(self.nameTextField.snp.width)
            make.centerX.equalToSuperview()
        }
        
        signupButton.snp.makeConstraints { make in
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-20)
            make.size.equalTo(self.nameTextField.snp.size)
            make.centerX.equalToSuperview()
        }
    }
    
    //MARK: SetBinding
    override func setBinding() {
        
        let input = SignUpViewModel.Input(
            nameText: nameTextField.rx.text.orEmpty,
            emailText: emailTextField.rx.text.orEmpty,
            passwordText: passwordTextField.rx.text.orEmpty,
            signUpTap: signupButton.rx.tap)
        let output = viewModel.transform(input: input)
        
        output.nameValid
            .drive(emailTextField.rx.isEnabled, nameValidLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        output.emailValid
            .drive(passwordTextField.rx.isEnabled, emailValidLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        output.passwordValid
            .drive(passwordValidLabel.rx.isHidden)
            .disposed(by: disposeBag)

        output.signUpValid
            .drive { [weak self] valid in
                guard let self = self else { return }
                self.signupButton.isEnabled = valid
                self.signupButton.backgroundColor = valid ? .systemOrange : .systemGray
            }
            .disposed(by: disposeBag)
        
        output.signUpTap
            .withUnretained(self)
            .subscribe { vc, _ in
                //vc.showAlert(title: "asd", button: "asd")
                vc.viewModel.signUpRequest()
            } onError: { error in
                print("=====\(error)")
            } onCompleted: {
                print("=====completed")
            } onDisposed: {
                print("=====disposed")
            }
            .disposed(by: disposeBag)

        viewModel.isSuccess
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .subscribe { vc, value in
                if value {
                    vc.showAlert(title: "회원가입완료!", button: "확인")
                }
            } onError: { _ in
                self.showAlert(title: "회원가입 실패!", button: "확인")
            } onCompleted: {
                print("======Completed")
            } onDisposed: {
                print("=======Disposed")
            }
            .disposed(by: disposeBag)

            
    }
}
