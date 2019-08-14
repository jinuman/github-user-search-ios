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
    var organizationItems: [OrganizationItem]
}

extension Organization: SectionModelType {
    var items: [OrganizationItem] {
        return self.organizationItems
    }
    
    init(original: Organization, items: [OrganizationItem]) {
        self = original
        self.organizationItems = items
    }
}

struct OrganizationItem: Codable, Equatable {
    let organizationImageUrl: String
    
    enum CodingKeys: String, CodingKey {
        case organizationImageUrl = "avatar_url"
    }
}
