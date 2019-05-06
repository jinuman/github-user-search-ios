//
//  UserSearchCell.swift
//  MyGithubUserSearch
//
//  Created by Jinwoo Kim on 06/05/2019.
//  Copyright © 2019 jinuman. All rights reserved.
//

import UIKit
import Then

class UserSearchCell: UICollectionViewCell {
    
    var userItem: UserItem? {
        didSet {
            fillupCell(with: userItem)
        }
    }
    
    private func fillupCell(with userItem: UserItem?) {
        guard let userItem = userItem else { return }
        profileImageView.loadImageUsingCache(with: userItem.avatarUrl)
        usernameLabel.text = userItem.username
        scoreLabel.text = "score: \(userItem.score.description)"
    }
    
    // MARK:- Cell screen properties
    private lazy var profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = Metric.profileImageSize / 2
        $0.backgroundColor = .cyan
    }
    
    private lazy var usernameLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 14)
        $0.textColor = .black
        $0.text = "jinuman"
    }
    
    private let scoreLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = .gray
        $0.text = "100.00"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupCellSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCellSubviews() {
        let stackView =  UIStackView(arrangedSubviews: [usernameLabel, scoreLabel])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = Metric.contentSpacing
        
        [profileImageView, stackView].forEach {
            addSubview($0)
        }
        
        profileImageView.anchor(top: topAnchor,
                                leading: leadingAnchor,
                                bottom: nil,
                                trailing: nil,
                                size: CGSize(width: Metric.profileImageSize, height: Metric.profileImageSize))
        
        stackView.anchor(top: topAnchor,
                         leading: profileImageView.trailingAnchor,
                         bottom: profileImageView.bottomAnchor,
                         trailing: trailingAnchor,
                         padding: UIEdgeInsets(top: 0, left: Metric.profileSpacing, bottom: 0, right: 0))
    }
}

