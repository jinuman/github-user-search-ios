//
//  Constants.swift
//  MyGithubUserSearch
//
//  Created by Jinwoo Kim on 06/05/2019.
//  Copyright © 2019 jinuman. All rights reserved.
//

import UIKit

import ReusableKit

struct Metric {
    static let profileImageSize: CGFloat = 50
    static let profileSpacing: CGFloat = 5
    static let contentSpacing: CGFloat = 3
    static let edgeInset: CGFloat = 25
    
    static let orgImageSize: CGFloat = 40
    static let orgBorderWidth: CGFloat = 0.5
    static let orgVerticalSpacing: CGFloat = 3
    static let orgItemSpacing: CGFloat = 5
}

enum Reusable {
    static let userSearchCell = ReusableCell<UserSearchCell>()
    static let organizationCell = ReusableCell<OrganizationCell>()
}
