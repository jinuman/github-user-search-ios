//
//  UserSearchReactor.swift
//  MyGithubUserSearch
//
//  Created by Jinwoo Kim on 06/05/2019.
//  Copyright © 2019 jinuman. All rights reserved.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa

class UserSearchReactor: Reactor {
    
    enum Action {
        case updateQuery(String?)
        case loadNextPage
    }
    
    enum Mutation {
        case setQuery(String?)
        case setUsers([UserInfo], nextPage: Int?)
        case appendUsers([UserInfo], nextPage: Int?)
        case setLoading(Bool)
    }
    
    struct State {
        var query: String?
        var items: [UserInfo] = []
        var nextPage: Int?
        var isLoading: Bool = false
    }
    
    // MARK: - Properties
    
    let initialState: State = State()
    
    // MARK: - Methods
    
    func mutate(action: UserSearchReactor.Action) -> Observable<UserSearchReactor.Mutation> {
        switch action {
        case .updateQuery(let query):
            return Observable.concat([
                /// 1) set current query
                Observable.just(Mutation.setQuery(query)),
                
                /// 2) API call -> setUsers
                GithubService.fetchUsers(with: query, page: 1)
                    .takeUntil(self.action.filter(self.isUpdateQueryAction))
                    .map { Mutation.setUsers($0.0, nextPage: $0.1) }
                ])
            
        case .loadNextPage:
            guard let nextPage = self.currentState.nextPage,
                self.currentState.isLoading == false else { return .empty() }
            
            return Observable.concat([
                
                /// 1) set loading true
                Observable.just(Mutation.setLoading(true)),
                
                /// 2) API call -> appendUsers
                GithubService.fetchUsers(with: self.currentState.query, page: nextPage)
                    .takeUntil(self.action.filter(isUpdateQueryAction))
                    .map { Mutation.appendUsers($0.0, nextPage: $0.1)},
                
                /// 3) set loading false
                Observable.just(Mutation.setLoading(false))
                ])
        }
    }
    
    func reduce(state: UserSearchReactor.State, mutation: UserSearchReactor.Mutation) -> UserSearchReactor.State {
        
        var newState = state
        
        switch mutation {
        case .setQuery(let query):
            newState.query = query
        case let .setUsers(users, nextPage):
            newState.items = users
            newState.nextPage = nextPage
        case let .appendUsers(users, nextPage):
            newState.items.append(contentsOf: users)
            newState.nextPage = nextPage
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
        }
        
        return newState
    }
    
    // .updateQuery action is fired -> true
    private func isUpdateQueryAction(_ action: Action) -> Bool {

        if case .updateQuery = action {
            return true
        } else {
            return false
        }
        
    }
}
