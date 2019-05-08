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
import RxDataSources
import ReactorKit

class UserSearchCell: UICollectionViewCell {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    var userItem: UserItem? {
        didSet {
            fillupCell(with: userItem)
        }
    }
    
    // MARK:- Cell screen properties
    private let tapGesture = UITapGestureRecognizer()
    
    private lazy var profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = Metric.profileImageSize / 2
        $0.isUserInteractionEnabled = true
    }
    
    private lazy var usernameLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 14)
        $0.textColor = .black
        $0.isUserInteractionEnabled = true
    }
    
    private let scoreLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = .gray
    }
    
    private let dataSource = RxCollectionViewSectionedReloadDataSource<OrganizationType>(configureCell: { (dataSource, collectionView, indexPath, item) -> UICollectionViewCell in

        let cell = collectionView.dequeue(Reusable.organizationCell, for: indexPath)
        cell.organization = item
        print("dataSource items: \(item.avatarUrl)")
        
        return cell
    })
    
    private let containerCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .cyan
        return cv
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupCellSubviews()
        
        containerCollectionView.register(Reusable.organizationCell)
        setupContainerCollectionView()
        
        profileImageView.addGestureRecognizer(tapGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        containerCollectionView.isHidden = false
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
    }
    
    private func fillupCell(with userItem: UserItem?) {
        guard let userItem = userItem else { return }
        profileImageView.loadImageUsingCache(with: userItem.avatarUrl)
        usernameLabel.text = userItem.username
        scoreLabel.text = "score: \(userItem.score.description)"
    }
    
    #warning("Need to refactor...")
    // ===== States =====
    var didTapCellItem: ((Bool, UICollectionViewCell) -> ())?
    var isTappedAgain: Bool = false
    // ===== ===== =====
}

extension UserSearchCell: View {
    
    func bind(reactor: UserSearchCellReactor) {
        
        containerCollectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        // Action Binding
        tapGesture.rx.event
            .take(1)
            .withLatestFrom(reactor.state)
            .map { $0.isTapped }
            .filter { $0 == false }
            .map { _ in self.userItem?.organizationsUrl}
            .map { Reactor.Action.updateOrganizationUrl($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // State Binding
        reactor.state
            .map { $0.organizations }
            .filter { $0.isEmpty == false }
            .map { [OrganizationType(items: $0)] }
            .bind(to: containerCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isTapped }
            .subscribe(onNext: { [weak self] isTapped in
                guard let self = self else { return }
                self.didTapCellItem?(isTapped, self)
            })
            .disposed(by: disposeBag)
        
        // miscellaneous.
    }
}

extension UserSearchCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: containerCollectionView.frame.height, height: Metric.orgImageSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Metric.orgItemSpacing
    }
}

