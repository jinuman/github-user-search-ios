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
        $0.backgroundColor = .red
    }
    
    private let spinner: UIActivityIndicatorView = UIActivityIndicatorView(style: .gray)
    
    // MARK:- Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupSubviews()
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
    
}

