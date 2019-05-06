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
    }
    
    enum Mutation {
        case setQuery(String?)
        case setUsers([User], nextPage: Int?)
    }
    
    let initialState: State = State()
    
    struct State {
        var query: String?
        var users = [User]()
    }
    
    func mutate(action: UserSearchReactor.Action) -> Observable<UserSearchReactor.Mutation> {
        switch action {
        case .updateQuery(let query):
            return Observable.concat([
                // step 1: set current query
                Observable.just(Mutation.setQuery(query)),
                
                // step 2: API call -> set users
                GithubService.search(with: query, page: 1)
                    .map { Mutation.setUsers($0.0, nextPage: $0.1) }
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
            return newState
        }
    }
}
