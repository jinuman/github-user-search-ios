//
//  UserSearchViewController.swift
//  MyGithubUserSearch
//
//  Created by Jinwoo Kim on 05/05/2019.
//  Copyright © 2019 jinuman. All rights reserved.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa
import RxDataSources
import Then

class UserSearchViewController: UIViewController {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK:- Sreen Properties
    private let userSearchBar = UISearchBar(frame: .zero).then {
        $0.searchBarStyle = .prominent
        $0.placeholder = "Github 사용자를 검색해보세요.."
        let textFieldInsideSearchBar = $0.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.backgroundColor = UIColor(r: 240, g: 240, b: 240)
    }
    
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        $0.backgroundColor = .white
        $0.register(Reusable.userSearchCell)
    }
    
    private lazy var dataSource = RxCollectionViewSectionedReloadDataSource<User>(configureCell: { (dataSource, collectionView, indexPath, userItem) -> UICollectionViewCell in
        
        let cell = collectionView.dequeue(Reusable.userSearchCell, for: indexPath)
        cell.userItem = userItem
        cell.didTapCellItem = self.didTapCellItem
        cell.flag = self.flag
        
        return cell
    })
    
    private let spinner: UIActivityIndicatorView = UIActivityIndicatorView(style: .gray)
    
    // MARK:- Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    // MARK:- Layout methods
    private func setupSubviews() {
        let navBar = navigationController?.navigationBar
        
        navBar?.addSubview(userSearchBar)
        [collectionView, spinner].forEach {
            view.addSubview($0)
        }
        
        userSearchBar.anchor(top: navBar?.topAnchor,
                         leading: navBar?.leadingAnchor,
                         bottom: navBar?.bottomAnchor,
                         trailing: navBar?.trailingAnchor,
                         padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
        
        collectionView.fillSuperview()
        
        spinner.centerInSuperview()
    }
    
    // ==== State ====
    var selectedIndexPaths = [IndexPath]()
    var flag: Bool = false
    
    // when tapped event
    private func didTapCellItem(isExpanded: Bool, cell: UICollectionViewCell) {
        flag = isExpanded
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        print("Clicked: \(indexPath)")
        
        if isExpanded {
            selectedIndexPaths.append(indexPath)
        } else {
            guard let idx = selectedIndexPaths.firstIndex(of: indexPath) else { return }
            selectedIndexPaths.remove(at: Int(idx))
        }
        collectionView.reloadData()
        print("## selectedIndexPath: \(selectedIndexPaths)")
    }
    // ===============
}

extension UserSearchViewController: View {
    func bind(reactor: UserSearchReactor) {
        
        // Action binding: View -> Reactor(Action)
        userSearchBar.rx.text
            .distinctUntilChanged()
            .debounce(DispatchTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .map { Reactor.Action.updateQuery($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        collectionView.rx.contentOffset
            .filter { [weak self] (offset) -> Bool in
                guard let self = self else { return false }
                
                let scrollPosition: CGFloat = offset.y
                let contentHeight: CGFloat = self.collectionView.contentSize.height
                
                return scrollPosition > contentHeight - self.collectionView.bounds.height
            }
            .map { _ in Reactor.Action.loadNextPage }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // State binding: Reactor(State) -> View
        reactor.state
            .map { $0.users }
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        // Misc.
        // Scroll to top if previous search text was scrolled
        userSearchBar.rx.text
            .withLatestFrom(collectionView.rx.contentOffset)
            .filter { $0.y > 0 }
            .subscribe({ [weak self] _ in
                guard let self = self else { return }
                self.collectionView.contentOffset.y = 0
            })
            .disposed(by: disposeBag)
    }
}

// MARK:- Regarding collectionView
extension UserSearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let guide = view.safeAreaLayoutGuide
        let width: CGFloat = guide.layoutFrame.width - Metric.edgeInset * 2
        if selectedIndexPaths.contains(indexPath) {
            let height: CGFloat = Metric.profileImageSize + Metric.orgImageSize + Metric.orgVerticalSpacing
            return CGSize(width: width, height: height)
        } else {
            let height: CGFloat = Metric.profileImageSize
            return CGSize(width: width, height: height)
        }
        
//        let width: CGFloat = guide.layoutFrame.width - Metric.edgeInset * 2
//        let frame = CGRect(x: 0, y: 0, width: width, height: 93)
//        let dummyCell = UserSearchCell(frame: frame)

////        dummyCell.org = orgs[indexPath.item]
//        dummyCell.layoutIfNeeded()  // after comment set
//
//        let targetSize = CGSize(width: view.frame.width, height: 100)
//        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
//
//        return CGSize(width: width, height: estimatedSize.height)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Metric.edgeInset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: Metric.edgeInset, left: 0, bottom: Metric.edgeInset, right: 0)
    }
}

