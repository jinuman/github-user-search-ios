//
//  UserSearchViewController.swift
//  MyGithubUserSearch
//
//  Created by Jinwoo Kim on 05/05/2019.
//  Copyright © 2019 jinuman. All rights reserved.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa
import RxDataSources
import ReactorKit

class UserSearchViewController: UIViewController, View {
    
    // MARK: - Properties
    
    private let userSearchBar: UISearchBar = {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.searchBarStyle = .prominent
        searchBar.placeholder = "Github 사용자를 검색해보세요.."
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.backgroundColor = UIColor(r: 240, g: 240, b: 240)
        return searchBar
    }()
    
    private let userTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.allowsSelection = false
        tableView.register(Reusable.userSearchCell)
        return tableView
    }()
    
    private typealias UserDataSource = RxTableViewSectionedReloadDataSource<UserSectionModel>
    
    private lazy var dataSource = UserDataSource(
        configureCell: { (dataSource, tableView, indexPath, userItem) -> UITableViewCell in
            let cell = tableView.dequeue(Reusable.userSearchCell, for: indexPath)
            cell.reactor = UserCellReactor(userItem: userItem)
            cell.didTapCellItem = self.didTapCellItem
            return cell
    })
    
    private let activityIndicatorView = UIActivityIndicatorView(style: .gray)
    
    // MARK: General
    
    var disposeBag: DisposeBag = DisposeBag()
    
    private var selectedIndexPaths = [IndexPath]()
    
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureLayout()
        self.addActions()
    }
    
    // MARK: - Binding
    
    func bind(reactor: UserSearchReactor) {
        
        // Action binding: View -> Reactor(Action)
        
        self.userSearchBar.rx.text
            .distinctUntilChanged()
            .throttle(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .map { Reactor.Action.updateQuery($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.userTableView.rx.contentOffset
            .filter { [weak self] offset -> Bool in
                guard let `self` = self else { return false }
                
                let scrollPosition: CGFloat = offset.y
                let contentHeight: CGFloat = self.userTableView.contentSize.height
                
                return scrollPosition > contentHeight - self.userTableView.bounds.height }
            .map { _ in Reactor.Action.loadNextPage }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // State binding: Reactor(State) -> View
        
        reactor.state.map { $0.items }
            .map { [UserSectionModel(items: $0)] }
            .bind(to: self.userTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isLoading }
            .bind(to: self.activityIndicatorView.rx.isAnimating)
            .disposed(by: disposeBag)
        
    }
    
    // MARK: - Methods
    
    private func configureLayout() {
        self.view.backgroundColor = .white
        
        self.navigationController?.navigationBar.addSubview(self.userSearchBar)
        
        self.view.addSubviews([
            self.userTableView,
            self.activityIndicatorView
        ])
        
        self.userSearchBar.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(10)
            $0.top.bottom.equalToSuperview()
        }
        
        self.userTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        self.activityIndicatorView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    private func addActions() {
        
        self.userTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        // Scroll to top if previous search text was scrolled
        self.userSearchBar.rx.text
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .withLatestFrom(self.userTableView.rx.contentOffset)
            .filter { $0.y > 0 }
            .subscribe({ [weak self] _ in
                guard let `self` = self else { return }
                self.userTableView.contentOffset.y = 0
            })
            .disposed(by: disposeBag)
        
        // Reset selectedIndexPaths when search bar text change
        self.userSearchBar.rx.text
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe({ [weak self] _ in
                guard let `self` = self else { return }
                self.selectedIndexPaths = []
            })
            .disposed(by: disposeBag)
        
    }
    
    // When tapped event came from cell
    private func didTapCellItem(isExpanded: Bool, cell: UITableViewCell) {
        
        guard let indexPath = self.userTableView.indexPath(for: cell) else { return }
        if isExpanded {
            self.selectedIndexPaths.append(indexPath)
        } else {
            guard let idx = self.selectedIndexPaths.firstIndex(of: indexPath) else { return }
            self.selectedIndexPaths.remove(at: Int(idx))
        }
        self.userTableView.reloadData()
    }
    
}

// MARK: - Extensions

extension UserSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let height: CGFloat = self.selectedIndexPaths.contains(indexPath)
        ? Metric.profileImageSize.width + Metric.edgeInset + Metric.orgImageSize.width + Metric.orgVerticalSpacing
        : Metric.profileImageSize.width + Metric.edgeInset + Metric.orgVerticalSpacing
        
        return height
    }
}

