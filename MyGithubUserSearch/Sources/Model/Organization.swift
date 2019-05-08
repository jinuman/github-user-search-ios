//
//  Organization.swift
//  MyGithubUserSearch
//
//  Created by Jinwoo Kim on 07/05/2019.
//  Copyright © 2019 jinuman. All rights reserved.
//

import Foundation
import RxDataSources

struct OrganizationType {
    var items: [Organization]
}

extension OrganizationType: SectionModelType {
    typealias Item = Organization
    
    init(original: OrganizationType, items: [Item]) {
        self = original
        self.items = items
    }
}

struct Organization: Decodable {
    let avatarUrl: String
    
    enum CodingKeys: String, CodingKey {
        case avatarUrl = "avatar_url"
    }
}
