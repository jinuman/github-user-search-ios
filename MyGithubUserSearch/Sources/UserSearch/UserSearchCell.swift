//
//  UserSearchCell.swift
//  MyGithubUserSearch
//
//  Created by Jinwoo Kim on 06/05/2019.
//  Copyright © 2019 jinuman. All rights reserved.
//

import UIKit
import Then
import RxSwift
import RxCocoa

class UserSearchCell: UICollectionViewCell {
    
    // MARK:- Cell screen properties
    private lazy var profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = Metric.profileImageSize / 2
        $0.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        $0.addGestureRecognizer(tapGesture)
    }
    
    private lazy var usernameLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 14)
        $0.textColor = .black
        $0.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        $0.addGestureRecognizer(tapGesture)
    }
    
    private let scoreLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = .gray
    }
    
    private let containerCollectionView = ContainerCollectionView().then {
        $0.backgroundColor = .cyan
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupCellSubviews()
        setupContainerCollectionView()
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
    
    private func setupContainerCollectionView() {
        addSubview(containerCollectionView)
        
        containerCollectionView.anchor(top: profileImageView.bottomAnchor,
                                       leading: leadingAnchor,
                                       bottom: bottomAnchor,
                                       trailing: trailingAnchor,
                                       padding: UIEdgeInsets(top: Metric.orgVerticalSpacing, left: 0, bottom: 0, right: 0))
        
//        containerHeightConstraint = containerCollectionView.heightAnchor.constraint(equalToConstant: 40)
//        containerHeightConstraint?.isActive = true
        
        containerCollectionView.dataSource = self
        containerCollectionView.delegate = self
//        containerCollectionView.isHidden = true
    }
    
    #warning("Need to refactor state.")
    // ===== States =====
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
    var orgs = [Organization]()
    var containerHeightConstraint: NSLayoutConstraint?
    var isTappedAgain: Bool = false
    var didTapCellItem: ((Bool, UICollectionViewCell) -> ())?
    var flag: Bool?
    
    @objc private func handleTapGesture() {
        profileImageView.isUserInteractionEnabled = false
        usernameLabel.isUserInteractionEnabled = false
        guard var isTapped: Bool = flag else { return }
        isTapped = !isTapped
        
        print("Before isTapped: \(isTapped)")
        
        if isTapped {
            if isTappedAgain == false {
                guard let url = URL(string: userItem?.organizationsUrl ?? "") else { return }
                // should implement : Fetching -> reload()
                self.fetchOrganizations(url: url) { (organizatoions) in
                    self.orgs = organizatoions
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        if self.orgs.isEmpty == false {
                            self.containerCollectionView.reloadData()
                            self.didTapCellItem?(isTapped, self)
                        }
                    })
                }
            }
            isTappedAgain = true
            
        } else {
            self.didTapCellItem?(isTapped, self)
        }
//        let containerHeight: CGFloat = isTapped ? Metric.orgImageSize : 0
//        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
//            self.containerHeightConstraint?.isActive = false
//            self.containerHeightConstraint?.constant = containerHeight
//            self.containerHeightConstraint?.isActive = true
//            self.containerCollectionView.layoutIfNeeded()
//        }, completion: nil)
//        containerCollectionView.isHidden = !isTapped
        DispatchQueue.main.async {
            if self.orgs.isEmpty == false {
                self.containerCollectionView.reloadData()
            }
        }
        
        print("After isTapped: \(isTapped)")
        
        profileImageView.isUserInteractionEnabled = true
        usernameLabel.isUserInteractionEnabled = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        containerCollectionView.isHidden = false
    }
    
    func fetchOrganizations(url: URL, completion: @escaping ([Organization]) -> ()) {
        let task = URLSession.shared.dataTask(with: url) { (data, res, err) in
            if let err = err {
                print(err.localizedDescription)
                return
            }
            
            guard let data = data else { return }
            do {
                let org = try JSONDecoder().decode([Organization].self, from: data)
                if org.isEmpty {
                    return // completion(error)
                }
                completion(org)
                
            } catch let jsonErr {
                print(jsonErr)
            }
        }
        task.resume()
    }
    // ===== ===== =====
    
}

extension UserSearchCell: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return orgs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(Reusable.organizationCell, for: indexPath)
        cell.org = orgs[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        if isTapped {
//            return CGSize(width: containerCollectionView.frame.height, height: Metric.orgImageSize)
//        } else {
//            return .zero
//        }
        return CGSize(width: containerCollectionView.frame.height, height: Metric.orgImageSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Metric.orgItemSpacing
    }
}

