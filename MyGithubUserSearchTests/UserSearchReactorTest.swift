//
//  UserSearchReactorTest.swift
//  MyGithubUserSearchTests
//
//  Created by tskim on 14/08/2019.
//  Copyright © 2019 jinuman. All rights reserved.
//

import Foundation
import XCTest
import RxExpect
@testable import MyGithubUserSearch

class UserSearchReactorTest: XCTestCase {
    
    
    var reactor: UserSearchReactor!
    var api: MockNetworkRequest!
    
    override func setUp() {
        super.setUp()
        api = MockNetworkRequest()
        api.setUserItems()
        reactor = UserSearchReactor(api: api)
    }
    
    func testIfEmptyKeyword() {
        // 빈 텍스트를 호출하면 isLoading 상태가 변경되지 않아야 함
        let rxExpect = RxExpect()
        rxExpect.retain(reactor)
        rxExpect.input(reactor.action, [
            .next(0, .updateQuery(""))
            ])
        rxExpect.assert(reactor.state.map { $0.isLoading }.filterNil()) { events in
            XCTAssertEqual(events, [])
        }
    }
    func testIncreaseNextPage() {
        // 호출하면 다음 페이지가 2로 증가하는지 검증
        let rxExpect = RxExpect()
        rxExpect.retain(reactor)
        
        rxExpect.input(reactor.action, [
            .next(0, .updateQuery("a"))
            ])
        rxExpect.assert(reactor.state.map { $0.nextPage }.filterNil()) { events in
            XCTAssertEqual(events, [
                .next(0, 2)
                ])
        }
    }
    func testSetStateQuery() {
        // query state가 정상적으로 변경되는지 검증
        let rxExpect = RxExpect()
        rxExpect.retain(reactor)
        
        rxExpect.input(reactor.action, [
            .next(0, .updateQuery("a"))
            ])
        rxExpect.assert(reactor.state.map { $0.query }.filterNil().distinctUntilChanged()) { events in
            XCTAssertEqual(events, [
                .next(0, "a")
                ])
        }
    }
    func testUserItemPaging() {
        // 페이징 동작이 잘 동작하는 지 검증
        let expect = [
            [Fixture.UserItems.sampleUserItems.shuffled().first!],
            [Fixture.UserItems.sampleUserItems.shuffled().first!],
            [Fixture.UserItems.sampleUserItems.shuffled().first!]
        ]
        api.setUserItemsPaging(expect)
        
        let rxExpect = RxExpect()
        rxExpect.retain(reactor)
        
        rxExpect.input(reactor.action, [
            .next(0, .updateQuery("a")),
            .next(10, .loadNextPage),
            .next(20, .loadNextPage),
            ])
        
        rxExpect.assert(reactor.state.map { $0.userItems }.filterEmpty()) { events in
            XCTAssertEqual(events.count, 3)
            XCTAssertEqual(events, [
                .next(0, expect[0]),
                .next(10, expect[1]),
                .next(20, expect[2])
                ])
        }
    }
    
}
