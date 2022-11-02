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
        setBinding()
    }
    
    func configure() { }
    
    func setConstraints() { }
    
    func setBinding() { }
}
