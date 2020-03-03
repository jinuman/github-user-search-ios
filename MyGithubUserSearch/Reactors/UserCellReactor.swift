//
//  UserCellReactor.swift
//  MyGithubUserSearch
//
//  Created by Jinwoo Kim on 07/05/2019.
//  Copyright © 2019 jinuman. All rights reserved.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa

class UserCellReactor: Reactor {
    
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
    
    func mutate(action: UserCellReactor.Action) -> Observable<UserCellReactor.Mutation> {
        switch action {
        case .updateOrganizationUrl(let urlString):
            return Observable.concat([
                GithubService.fetchOrganizations(with: urlString)
                    .takeUntil(self.action.filter(isUpdateUrlAction))
                    .map { Mutation.setOrganizationItems($0) },
                
                Observable.just(Mutation.setIsTapped(true))
                ])
        }
    }
    
    func reduce(state: UserCellReactor.State, mutation: UserCellReactor.Mutation) -> UserCellReactor.State {
        switch mutation {
        case .setOrganizationItems(let organizations):
            var newState = state
            newState.organizationItems = organizations
            let printMessage: String = newState.organizationItems.isEmpty
                ? "No organizations"
                : "State organization itmes: \(newState.organizationItems.count)"
            print(printMessage)
            return newState
            
        case .setIsTapped(let isTapped):
            var newState = state
            newState.isTapped = isTapped
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
