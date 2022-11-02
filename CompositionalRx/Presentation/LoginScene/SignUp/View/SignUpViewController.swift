//
//  SignUpViewController.swift
//  CompositionalRx
//
//  Created by Seo Jae Hoon on 2022/11/02.
//

import UIKit
import RxCocoa
import RxSwift

final class SignUpViewController: BaseViewController {
    
    // 고려할 점: 회원가입 시 비밀번호는 재입력을 하는 부분도 있다.
    //MARK: Property
    private let disposeBag = DisposeBag()
    
    private let viewModel = SignUpViewModel()
    
    private lazy var nameTextField: UITextField = UITextField().then {
        $0.font = .systemFont(ofSize: 14)
        $0.layer.cornerRadius = 5
        $0.layer.borderWidth = 1
    }
    
    private lazy var nameValidLabel: UILabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12)
        $0.textColor = .systemGray
    }
    
    private lazy var emailTextField: UITextField = UITextField().then {
        $0.font = .systemFont(ofSize: 14)
        $0.layer.cornerRadius = 5
        $0.layer.borderWidth = 1
        $0.isHidden = true
    }
    
    private lazy var emailValidLabel: UILabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12)
        $0.textColor = .systemGray
        $0.isHidden = true
    }
    
    private lazy var passwordTextField: UITextField = UITextField().then {
        $0.font = .systemFont(ofSize: 14)
        $0.layer.cornerRadius = 5
        $0.layer.borderWidth = 1
        $0.keyboardType = .asciiCapable
        $0.isHidden = true
    }
    
    private lazy var passwordValidLabel: UILabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12)
        $0.textColor = .systemGray
        $0.isHidden = true
    }
    
    private lazy var signupButton: UIButton = UIButton().then {
        $0.isEnabled = true
        $0.setTitle("회원가입!!", for: .normal)
        $0.backgroundColor = .systemOrange
    }
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //MARK: COnfigure UI
    override func configure() {
        [nameTextField, nameValidLabel, emailTextField, emailValidLabel, passwordTextField, passwordValidLabel, signupButton].forEach{ self.view.addSubview($0)}
    }
    
    override func setConstraints() {
        self.nameTextField.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(16)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
        
        self.nameValidLabel.snp.makeConstraints { make in
            make.top.equalTo(self.nameTextField.snp.bottom).offset(16)
            make.width.equalTo(self.nameTextField.snp.width)
            make.centerX.equalToSuperview()
        }
        
        self.emailTextField.snp.makeConstraints { make in
            make.top.equalTo(self.nameValidLabel.snp.bottom).offset(16)
            make.size.equalTo(self.nameTextField.snp.size)
            make.centerX.equalToSuperview()
        }
        
        self.emailValidLabel.snp.makeConstraints { make in
            make.top.equalTo(self.emailTextField.snp.bottom).offset(16)
            make.width.equalTo(self.nameTextField.snp.width)
            make.centerX.equalToSuperview()
        }
        
        self.passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(self.emailValidLabel.snp.bottom).offset(16)
            make.size.equalTo(self.nameTextField.snp.size)
            make.centerX.equalToSuperview()
        }
        
        self.passwordValidLabel.snp.makeConstraints { make in
            make.top.equalTo(self.passwordTextField.snp.bottom).offset(16)
            make.width.equalTo(self.nameTextField.snp.width)
            make.centerX.equalToSuperview()
        }
        
        self.signupButton.snp.makeConstraints { make in
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-16)
            make.size.equalTo(self.nameTextField.snp.size)
            make.centerX.equalToSuperview()
        }
    }
    
    //MARK: SetBinding
    override func setBinding() {
        
        nameTextField.rx.text.orEmpty
            .asDriver()
            .drive { [weak self] value in
                guard let self = self else { return }
                self.viewModel.name.accept(value)
            }
            .disposed(by: disposeBag)
            
        
        emailTextField.rx.text.orEmpty
            .asDriver()
            .drive { [weak self] value in
                guard let self = self else { return }
                self.viewModel.email.accept(value)
            }
            .disposed(by: disposeBag)
        
        passwordTextField.rx.text.orEmpty
            .asDriver()
            .drive { [weak self] value in
                self?.viewModel.password.accept(value)
            }
            .disposed(by: disposeBag)
        
        
        
    }
}
