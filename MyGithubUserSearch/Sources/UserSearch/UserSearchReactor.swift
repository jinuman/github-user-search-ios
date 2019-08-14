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
    
    let initialState: State = State()
    private let api: NetworkRequest
    
    init(api: NetworkRequest) {
        self.api = api
    }
    
    enum Action {
        case updateQuery(String?)
        case loadNextPage
    }
    
    enum Mutation {
        case setQuery(String?)
        case setUsers([UserItem], nextPage: Int?)
        case appendUsers([UserItem], nextPage: Int?)
        case setLoading(Bool)
    }
    
    struct State {
        var query: String?
        var userItems = [UserItem]()
        var nextPage: Int?
        var isLoading: Bool?
    }
    
    func mutate(action: UserSearchReactor.Action) -> Observable<UserSearchReactor.Mutation> {
        switch action {
        case .updateQuery(let query):
            return Observable.concat([
                //Review: [사용성] 사용자에게 로딩을 보여줘야 합니다.
//                Observable.just(Mutation.setLoading(true)),
                // step 1: set current query
                Observable.just(Mutation.setQuery(query)),
                
                // step 2: API call -> set users
                // Review: GithubAPI 는 주입을 받을 수 있도록 해야 합니다.
                // 지금의 목표는 TestCode를 짜기 위함
                self.api.fetchUsers(with: query, page: 1)
                    .takeUntil(self.action.filter(isUpdateQueryAction))
                    .map { Mutation.setUsers($0.0, nextPage: $0.1) },
//                Observable.just(Mutation.setLoading(false)),
                ])
            
        case .loadNextPage:
            guard let nextPage = currentState.nextPage,
                currentState.isLoading == false else { return .empty() }
            
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                // API call -> append users
                self.api.fetchUsers(with: currentState.query, page: nextPage)
                    .takeUntil(self.action.filter(isUpdateQueryAction))
                    .map { Mutation.appendUsers($0.0, nextPage: $0.1)},
                Observable.just(Mutation.setLoading(false))
                ])
        }
    }
    
    func reduce(state: UserSearchReactor.State, mutation: UserSearchReactor.Mutation) -> UserSearchReactor.State {
        // step 3: state change
        var newState = state
        switch mutation {
        case .setQuery(let query):
            newState.query = query
            return newState
            
        case let .setUsers(users, nextPage):
            newState.userItems = users
            newState.nextPage = nextPage
            return newState
            
        case let .appendUsers(users, nextPage):
            newState.userItems.append(contentsOf: users)
            newState.nextPage = nextPage
            return newState
            
        case .setLoading(let isLoading):
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
