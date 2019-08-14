//
//  RxTestScheduler.swift
//  MyGithubUserSearchTests
//
//  Created by tskim on 14/08/2019.
//  Copyright © 2019 jinuman. All rights reserved.
//
import Foundation
import RxSwift
import RxTest
@testable import MyGithubUserSearch

class RxTestScheduler: RxSchedulerType {
    var network: SchedulerType
    let io: SchedulerType
    let main: SchedulerType
    
    init(_ scheduler: TestScheduler) {
        self.io = scheduler
        self.main = scheduler
        self.network = scheduler
    }
}
