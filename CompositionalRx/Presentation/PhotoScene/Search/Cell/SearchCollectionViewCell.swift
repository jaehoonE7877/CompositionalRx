//
//  SearchCollectionViewCell.swift
//  CompositionalRx
//
//  Created by Seo Jae Hoon on 2022/11/02.
//

import UIKit

final class SearchCollectionViewCell: UICollectionViewCell {
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let likeLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 14)
        view.textColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func configureUI() {
        
        [imageView, likeLabel].forEach { contentView.addSubview($0)}
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8),
            
            likeLabel.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 4),
            likeLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8),
            likeLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -8)
            
        ])
    }
    
}
