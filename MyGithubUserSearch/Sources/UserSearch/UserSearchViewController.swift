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

class UserSearchViewController: UIViewController {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    private var selectedIndexPaths = [IndexPath]()
    
    // MARK:- Sreen Properties
    private let userSearchBar: UISearchBar = {
        let sb = UISearchBar(frame: .zero)
        sb.searchBarStyle = .prominent
        sb.placeholder = "Github 사용자를 검색해보세요.."
        let textFieldInsideSearchBar = sb.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.backgroundColor = UIColor(r: 240, g: 240, b: 240)
        return sb
    }()
    
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.separatorStyle = .none
        tv.backgroundColor = .white
        return tv
    }()
    
    typealias UserDataSource = RxTableViewSectionedReloadDataSource<User>
    
    private lazy var dataSource = UserDataSource(configureCell: { (dataSource, tableView, indexPath, userItem) -> UITableViewCell in
        
        let cell = tableView.dequeue(Reusable.userSearchCell, for: indexPath)
        cell.reactor = UserSearchCellReactor()
        cell.userItem = userItem
        cell.didTapCellItem = self.didTapCellItem
        return cell
    })
    
    private let spinner: UIActivityIndicatorView = UIActivityIndicatorView(style: .gray)
    
    // MARK:- Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.register(Reusable.userSearchCell)
        
        setupSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    // MARK:- Layout methods
    private func setupSubviews() {
        let navBar = navigationController?.navigationBar
        
        navBar?.addSubview(userSearchBar)
        [tableView, spinner].forEach {
            view.addSubview($0)
        }
        
        userSearchBar.anchor(top: navBar?.topAnchor,
                         leading: navBar?.leadingAnchor,
                         bottom: navBar?.bottomAnchor,
                         trailing: navBar?.trailingAnchor,
                         padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
        
        tableView.fillSuperview()
        
        spinner.centerInSuperview()
    }
    
    // When tapped event come
    private func didTapCellItem(isExpanded: Bool, cell: UITableViewCell) {
        
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        if isExpanded {
            selectedIndexPaths.append(indexPath)
        } else {
            guard let idx = selectedIndexPaths.firstIndex(of: indexPath) else { return }
            selectedIndexPaths.remove(at: Int(idx))
        }
        tableView.reloadData()
//        print("## selectedIndexPath: \(selectedIndexPaths)")
    }
    
    var isSearching: Bool = false
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
        
        tableView.rx.contentOffset
            .filter { [weak self] (offset) -> Bool in
                guard let self = self else { return false }
                
                let scrollPosition: CGFloat = offset.y
                let contentHeight: CGFloat = self.tableView.contentSize.height
                
                return scrollPosition > contentHeight - self.tableView.bounds.height
            }
            .map { _ in Reactor.Action.loadNextPage }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // State binding: Reactor(State) -> View
        reactor.state
            .map { $0.userItems }
            .map { [User(userItems: $0)] }
            .observeOn(MainScheduler.asyncInstance)
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isLoading }
            .bind(to: spinner.rx.isAnimating)
            .disposed(by: disposeBag)
        
        // Misc.
        // Scroll to top if previous search text was scrolled
        userSearchBar.rx.text
            .debounce(DispatchTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .withLatestFrom(tableView.rx.contentOffset)
            .filter { $0.y > 0 }
            .subscribe({ [weak self] _ in
                guard let self = self else { return }
                self.tableView.contentOffset.y = 0
            })
            .disposed(by: disposeBag)
        
        userSearchBar.rx.text
            .debounce(DispatchTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe({ [weak self] _ in
                guard let self = self else { return }
                self.selectedIndexPaths = []
            })
            .disposed(by: disposeBag)
    }
}

// MARK:- Regarding tableView delegate
extension UserSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let height: CGFloat = selectedIndexPaths.contains(indexPath) && !isSearching
            ? Metric.profileImageSize + Metric.edgeInset + Metric.orgImageSize + Metric.orgVerticalSpacing
            : Metric.profileImageSize + Metric.edgeInset + Metric.orgVerticalSpacing
        
        return height
    }
    
}

