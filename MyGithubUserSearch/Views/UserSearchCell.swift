//
//  UserSearchCell.swift
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

class UserSearchCell: UITableViewCell {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    var didTapCellItem: ((Bool, UITableViewCell) -> ())?
    private var isTapped: Bool = false
    
    // MARK:- Cell screen properties
    private let tapGestureByImage: UITapGestureRecognizer = UITapGestureRecognizer()
    private let tapGestureByLabel: UITapGestureRecognizer = UITapGestureRecognizer()
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(tapGestureByImage)
        return iv
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
    
    private lazy var containerCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.register(Reusable.organizationCell)
        cv.alwaysBounceHorizontal = true
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
    
    // MARK:- Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupCellSubviews()
        setupContainerCollectionView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let inset: CGFloat = Metric.edgeInset
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: inset / 2, left: inset, bottom: inset / 2, right: inset))
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- Setup layout methods
    private func setupCellSubviews() {
        let stackView =  UIStackView(arrangedSubviews: [usernameLabel, scoreLabel])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = Metric.contentSpacing
        
        [profileImageView, stackView].forEach {
            contentView.addSubview($0)
        }
        
        profileImageView.anchor(top: contentView.topAnchor,
                                leading: contentView.leadingAnchor,
                                bottom: nil,
                                trailing: nil,
                                size: CGSize(width: Metric.profileImageSize, height: Metric.profileImageSize))
        profileImageView.layer.cornerRadius = Metric.profileImageSize / 2
        
        stackView.anchor(top: contentView.topAnchor,
                         leading: profileImageView.trailingAnchor,
                         bottom: profileImageView.bottomAnchor,
                         trailing: contentView.trailingAnchor,
                         padding: UIEdgeInsets(top: 0, left: Metric.profileSpacing, bottom: 0, right: 0))
    }
    
    private func setupContainerCollectionView() {
        contentView.addSubview(containerCollectionView)
        
        containerCollectionView.anchor(top: profileImageView.bottomAnchor,
                                       leading: contentView.leadingAnchor,
                                       bottom: contentView.bottomAnchor,
                                       trailing: contentView.trailingAnchor,
                                       padding: UIEdgeInsets(top: Metric.orgVerticalSpacing, left: 0, bottom: 0, right: 0))
    }
    
    // MARK:- Fillup cell with Reactor
    private func fillupCell(with reactor: UserSearchCellReactor) {
        let userItem: UserItem = reactor.currentState.userItem
        
        guard let profileImageUrl = URL(string: userItem.profileImageUrl) else { return }
        self.profileImageView.setImage(with: profileImageUrl)
        self.usernameLabel.text = userItem.username
        let scoreText: String = "score: \(userItem.score.description)"
        self.scoreLabel.text = scoreText
    }
}

extension UserSearchCell: ReactorKit.View {
    func bind(reactor: UserSearchCellReactor) {
        self.fillupCell(with: reactor)
        
        // DataSource
        containerCollectionView.rx.setDelegate(self)
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
            .bind(to: containerCollectionView.rx.items(dataSource: dataSource))
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

extension UserSearchCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return isTapped
            ? CGSize(width: Metric.orgImageSize, height: Metric.orgImageSize)
            : .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Metric.orgItemSpacing
    }
}

