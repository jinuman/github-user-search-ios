//
//  UserSearchCellReactor.swift
//  MyGithubUserSearch
//
//  Created by Jinwoo Kim on 07/05/2019.
//  Copyright © 2019 jinuman. All rights reserved.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa

class UserSearchCellReactor: Reactor {
    
    let initialState: State
    
    init(userItem: UserItem) {
        self.initialState = State(userItem: userItem)
    }
    
    enum Action {
        case updateOrganizationUrl(String?)
    }
    
    enum Mutation {
        case setOrganizationItems([OrganizationItem])
        case setIsTapped(Bool)
    }
    
    struct State {
        let userItem: UserItem
        var organizationItems: [OrganizationItem]
        var isTapped: Bool = false
        
        init(userItem: UserItem, organizationItems: [OrganizationItem] = [], isTapped: Bool = false) {
            self.userItem = userItem
            self.organizationItems = organizationItems
            self.isTapped = isTapped
        }
    }
    
    func mutate(action: UserSearchCellReactor.Action) -> Observable<UserSearchCellReactor.Mutation> {
        switch action {
        case .updateOrganizationUrl(let urlString):
            return Observable.concat([
                GithubAPI.fetchOrganizations(with: urlString)
                    .takeUntil(self.action.filter(isUpdateUrlAction))
                    .map { Mutation.setOrganizationItems($0) },
                
                Observable.just(Mutation.setIsTapped(true))
                ])
        }
    }
    
    func reduce(state: UserSearchCellReactor.State, mutation: UserSearchCellReactor.Mutation) -> UserSearchCellReactor.State {
        switch mutation {
        case .setOrganizationItems(let organizations):
            var newState = state
            newState.organizationItems = organizations
            print("[State] orgs: \(newState.organizationItems.count)")
            return newState
            
        case .setIsTapped(let isTapped):
            var newState = state
            newState.isTapped = isTapped
//            print("[State] isTapped: \(newState.isTapped)")
            return newState
        }
    }
    
    private func isUpdateUrlAction(_ action: Action) -> Bool {
        if case .updateOrganizationUrl = action {
            return true
        } else {
            return false
        }
    }
}
