//
//  Fixture.swift
//  TddMVVMGithubTests
//
//  Created by tskim on 10/08/2019.
//  Copyright © 2019 hucet. All rights reserved.
//

import Foundation
@testable import MyGithubUserSearch

struct Fixture {
    struct UserItems {
        static let sampleUserItems: [UserItem] = ResourcesLoader.loadJson("sample_user_item")
        static var first: UserItem {
            return sampleUserItems.first!
        }
    }
    struct Organizations {
        static let sampleOrganization: [OrganizationItem] = ResourcesLoader.loadJson("sample_organization")
        static var first: OrganizationItem {
            return sampleOrganization.first!
        }
    }
}
