//
//  Organization+Equal.swift
//  MyGithubUserSearchTests
//
//  Created by tskim on 14/08/2019.
//  Copyright © 2019 jinuman. All rights reserved.
//

import Foundation
@testable import MyGithubUserSearch

extension Organization: Equatable {
    public static func == (lhs: Organization, rhs: Organization) -> Bool {
        return lhs.items == rhs.items
    }
}
