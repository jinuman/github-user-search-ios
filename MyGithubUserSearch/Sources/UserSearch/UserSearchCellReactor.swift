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
    
    enum Action {
        case updateOrganizationUrl(String?)
    }
    
    enum Mutation {
        case setOrganizationUrl(String?)
        
        case setAvatarUrls([OrganizationItem])
        
        case setIsTapped(Bool)
    }
    
    let initialState: State = State()
    
    struct State {
        var organizationUrlString: String?
        var avatarUrls = [OrganizationItem]()
        
        var isTapped: Bool = false
    }
    
    func mutate(action: UserSearchCellReactor.Action) -> Observable<UserSearchCellReactor.Mutation> {
        switch action {
        case .updateOrganizationUrl(let urlString):
            return Observable.concat([
                Observable.just(Mutation.setOrganizationUrl(urlString)),
                
                GithubService.fetchOrganizations(with: urlString)
                    .takeUntil(self.action.filter(isUpdateUrlAction))
                    .map { Mutation.setAvatarUrls($0) },
                
                Observable.just(Mutation.setIsTapped(true))
                ])
        }
    }
    
    func reduce(state: UserSearchCellReactor.State, mutation: UserSearchCellReactor.Mutation) -> UserSearchCellReactor.State {
        switch mutation {
            
        case .setOrganizationUrl(let urlString):
            var newState = state
            newState.organizationUrlString = urlString
            return newState
            
        case .setAvatarUrls(let organizations):
            var newState = state
            newState.avatarUrls = organizations
            print("[State] orgs: \(newState.avatarUrls.count)")
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
