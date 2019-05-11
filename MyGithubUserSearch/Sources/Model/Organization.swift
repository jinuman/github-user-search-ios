//
//  Organization.swift
//  MyGithubUserSearch
//
//  Created by Jinwoo Kim on 07/05/2019.
//  Copyright © 2019 jinuman. All rights reserved.
//

import Foundation
import RxDataSources

struct Organization {
    var items: [OrganizationItem]
}

extension Organization: SectionModelType {
    typealias Item = OrganizationItem
    
    init(original: Organization, items: [Item]) {
        self = original
        self.items = items
    }
}

struct OrganizationItem: Decodable {
    let avatarUrl: String
    
    enum CodingKeys: String, CodingKey {
        case avatarUrl = "avatar_url"
    }
}
