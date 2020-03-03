//
//  UserTableViewCell.swift
//  MyGithubUserSearch
//
//  Created by Jinwoo Kim on 06/05/2019.
//  Copyright © 2019 jinuman. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import ReactorKit

class UserTableViewCell: UITableViewCell {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    var didTapCellItem: ((Bool, UITableViewCell) -> ())?
    private var isTapped: Bool = false
    
    // MARK:- Cell screen properties
    private let tapGestureByImage: UITapGestureRecognizer = UITapGestureRecognizer()
    private let tapGestureByLabel: UITapGestureRecognizer = UITapGestureRecognizer()
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.layer.cornerRadius = Metric.profileImageSize.width / 2.0
        imageView.addGestureRecognizer(self.tapGestureByImage)
        return imageView
    }()
    
    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .black
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tapGestureByLabel)
        return label
    }()
    
    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        return label
    }()
    
    typealias OrganizationDataSource = RxCollectionViewSectionedReloadDataSource<Organization>
    
    private let dataSource = OrganizationDataSource(configureCell: { (dataSource, collectionView, indexPath, item) -> UICollectionViewCell in
        let cell = collectionView.dequeue(Reusable.organizationCell, for: indexPath)
        
        if let url = URL(string: item.organizationImageUrl) {
            
            cell.organizationImageView.setImage(with: url)
        }
        return cell
    })
    
    private lazy var organizationCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.register(Reusable.organizationCell)
        collectionView.alwaysBounceHorizontal = true
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    // MARK: - Initializing
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.initializeLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let inset: CGFloat = Metric.edgeInset
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: inset / 2, left: inset, bottom: inset / 2, right: inset))
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    private func initializeLayout() {
        let stackView =  UIStackView(arrangedSubviews: [
            self.usernameLabel,
            self.scoreLabel
        ])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = Metric.contentSpacing
        
        self.addSubviews([
            self.profileImageView,
            stackView,
            self.organizationCollectionView
        ])
        
        self.profileImageView.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.size.equalTo(Metric.profileImageSize)
        }
        
        stackView.snp.makeConstraints {
            $0.top.trailing.equalToSuperview()
            $0.leading.equalTo(self.profileImageView.snp.trailing).offset(Metric.profileSpacing)
        }
        
        self.organizationCollectionView.snp.makeConstraints {
            $0.top.equalTo(self.profileImageView.snp.bottom).offset(Metric.orgVerticalSpacing)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func fillupCell(with reactor: UserSearchCellReactor) {
        let userItem: UserItem = reactor.currentState.userItem
        
        guard let profileImageUrl = URL(string: userItem.profileImageUrl) else { return }
        self.profileImageView.setImage(with: profileImageUrl)
        self.usernameLabel.text = userItem.username
        let scoreText: String = "score: \(userItem.score.description)"
        self.scoreLabel.text = scoreText
    }
}

extension UserTableViewCell: ReactorKit.View {
    func bind(reactor: UserSearchCellReactor) {
        self.fillupCell(with: reactor)
        
        // DataSource
        organizationCollectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        // Action Binding
        Observable.of(tapGestureByImage.rx.event, tapGestureByLabel.rx.event)
            .merge()
            .withLatestFrom(reactor.state)
            .map { $0.isTapped }
            .filter { $0 == false }
            .map { _ in reactor.currentState.userItem.organizationsUrl}
            .map { Reactor.Action.updateOrganizationUrl($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // State Binding
        reactor.state
            .map { $0.organizationItems }
            .distinctUntilChanged()
            .filter { $0.isEmpty == false }
            .map { [Organization(organizationItems: $0)] }
            .observeOn(MainScheduler.asyncInstance)
            .bind(to: organizationCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.organizationItems }
            .filter { $0.isEmpty == false }  // If selected user has organization, send down
            .withLatestFrom(reactor.state)
            .map { $0.isTapped }
            .subscribe(onNext: { [weak self] isTapped in
                guard let self = self else { return }
                self.didTapCellItem?(isTapped, self)
                self.isTapped = isTapped
            })
            .disposed(by: disposeBag)
    }
}

extension UserTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return isTapped ? Metric.orgImageSize : .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Metric.orgItemSpacing
    }
}

