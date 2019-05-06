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
        case setUsers([User], nextPage: Int?)
        case appendUsers([User], nextPage: Int?)
        case setLoading(Bool)
    }
    
    let initialState: State = State()
    
    struct State {
        var query: String?
        var users = [User]()
        var nextPage: Int?
        var isLoading: Bool = false
    }
    
    func mutate(action: UserSearchReactor.Action) -> Observable<UserSearchReactor.Mutation> {
        switch action {
        case .updateQuery(let query):
            return Observable.concat([
                // step 1: set current query
                Observable.just(Mutation.setQuery(query)),
                
                // step 2: API call -> set users
                GithubService.search(with: query, page: 1)
                    .takeUntil(self.action.filter(isUpdateQueryAction))
                    .map { Mutation.setUsers($0.0, nextPage: $0.1) }
                ])
            
        case .loadNextPage:
            guard
                let nextPage = currentState.nextPage,
                currentState.isLoading == false else { return .empty() }
            
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                // API call -> append users
                GithubService.search(with: currentState.query, page: nextPage)
                    .takeUntil(self.action.filter(isUpdateQueryAction))
                    .map { Mutation.appendUsers($0.0, nextPage: $0.1)},
                Observable.just(Mutation.setLoading(false))
                ])
        }
    }
    
    func reduce(state: UserSearchReactor.State, mutation: UserSearchReactor.Mutation) -> UserSearchReactor.State {
        // step 3: state change
        switch mutation {
        case .setQuery(let query):
            var newState = state
            newState.query = query
            return newState
            
        case let .setUsers(users, nextPage):
            var newState = state
            newState.users = users
            newState.nextPage = nextPage
            return newState
            
        case let .appendUsers(users, nextPage):
            var newState = state
            newState.users.append(contentsOf: users)
            newState.nextPage = nextPage
            return newState
            
        case .setLoading(let isLoading):
            var newState = state
            newState.isLoading = isLoading
            return newState
        }
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
