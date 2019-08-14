//
//  MockNetworkRequestProtocol+Mocking.swift
//  TddMVVMGithubTests
//
//  Created by tskim on 10/08/2019.
//  Copyright © 2019 hucet. All rights reserved.
//

import Foundation
import Cuckoo
import RxSwift
@testable import MyGithubUserSearch

extension MockNetworkRequest {
    @discardableResult
    func setUserItems(_ items: [UserItem]? = nil, error: Error? = nil) -> ([UserItem]?, Error?) {
        let mockData = items ?? Fixture.UserItems.sampleUserItems
        stub(self, block: { mock in



            when(mock.fetchUsers(with: any(), page: any()))
                .then { _ in
                    Observable.just(mockData)
                        .map {
                            if let error = error {
                                throw error
                            } else {
                                return ($0, 2)
                            }
                    }
            }
        })
        return (mockData, error)
    }
    @discardableResult
    func setUserItemsPaging(_ items: [[UserItem]]) -> [[UserItem]] {
        stub(self, block: { mock in
            for (index, item) in items.enumerated() {
                when(mock.fetchUsers(with: any(), page: equal(to: index)))
                    .then { _ in return Observable.just((item, index)) }
            }
        })
        return items
    }
}
