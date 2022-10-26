//
//  BaseViewController.swift
//  CompositionalRx
//
//  Created by Seo Jae Hoon on 2022/10/26.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
        setConstraints()
    }
    
    func configure() { }
    
    func setConstraints() {}
    
    func showAlertMessage(title: String, button: String = "확인") {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let ok = UIAlertAction(title: button, style: .default)
        alert.addAction(ok)
        present(alert, animated: true)
    }
}
