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
import Kingfisher

class UserSearchCell: UITableViewCell {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    var userItem: UserItem? {
        didSet {
            fillupCell(with: userItem)
        }
    }
    
    var didTapCellItem: ((Bool, UITableViewCell) -> ())?
    
    // MARK:- Cell screen properties
    private let tapGestureByImage = UITapGestureRecognizer()
    private let tapGestureByLabel = UITapGestureRecognizer()
    
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
            cell.organizationImageView.kf.setImage(with: url)
        }
//        print("dataSource avatar: \(item.organizationImageUrl)")
        return cell
    })
    
    private let containerCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        return cv
    }()
    
    // MARK:- Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupCellSubviews()
        
        containerCollectionView.register(Reusable.organizationCell)
        setupContainerCollectionView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let inset: CGFloat = Metric.edgeInset
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: inset / 2, left: inset, bottom: inset / 2, right: inset))
    }
    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        containerCollectionView.isHidden = false
//    }
    
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
    
    private func fillupCell(with userItem: UserItem?) {
        guard let userItem = userItem else { return }
        profileImageView.loadImageUsingCache(with: userItem.profileImageUrl)
        usernameLabel.text = userItem.username
        scoreLabel.text = "score: \(userItem.score.description)"
    }
    
    #warning("Need to refactor")
    // == States ==
    var isTappedAgain: Bool = false
}

extension UserSearchCell: ReactorKit.View {
    
    func bind(reactor: UserSearchCellReactor) {
        
        // DataSource
        containerCollectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        // Action Binding
        Observable.of(tapGestureByImage.rx.event, tapGestureByLabel.rx.event)
            .merge()
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
            .map { $0.avatarUrls }
            .distinctUntilChanged()
            .filter { $0.isEmpty == false }
            .map { [Organization(organizationItems: $0)] }
            .observeOn(MainScheduler.asyncInstance)
            .bind(to: containerCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isTapped }
            .subscribe(onNext: { [weak self] isTapped in
                guard let self = self else { return }
                self.didTapCellItem?(isTapped, self)
            })
            .disposed(by: disposeBag)
    }
}

extension UserSearchCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Metric.orgImageSize, height: Metric.orgImageSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Metric.orgItemSpacing
    }
}

