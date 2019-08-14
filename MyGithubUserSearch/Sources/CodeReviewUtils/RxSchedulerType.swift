//
//  RxSchedulerType.swift
//  MyGithubUserSearch
//
//  Created by tskim on 14/08/2019.
//  Copyright © 2019 jinuman. All rights reserved.
//

import Foundation
import RxSwift

protocol RxSchedulerType {
    var io: SchedulerType { get }
    var network: SchedulerType { get }
    var main: SchedulerType { get }
}

class RxScheduler: RxSchedulerType {
    let network: SchedulerType = ConcurrentDispatchQueueScheduler(qos: .utility)
    
    let io: SchedulerType = ConcurrentDispatchQueueScheduler(qos: .utility)
    
    let main: SchedulerType = MainScheduler()
}
