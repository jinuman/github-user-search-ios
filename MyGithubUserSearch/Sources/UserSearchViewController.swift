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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        _ = GithubService.search(with: "vingle", page: 0)
            .subscribe(onNext: {
                print($0)
            })
            .disposed(by: disposeBag)
    }
    
}

