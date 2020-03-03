//
//  OrganizationInfo.swift
//  MyGithubUserSearch
//
//  Created by Jinwoo Kim on 07/05/2019.
//  Copyright © 2019 jinuman. All rights reserved.
//

import Foundation
import RxDataSources

struct OrganizationInfo: Decodable, Equatable {
    let organizationImageUrl: String
    
    enum CodingKeys: String, CodingKey {
        case organizationImageUrl = "avatar_url"
    }
}

struct OrganizationSectionModel {
    
    var items: [Item]
    
}

extension OrganizationSectionModel: SectionModelType {
    
    typealias Item = OrganizationInfo
    
    init(original: OrganizationSectionModel, items: [Item]) {
        self = original
        self.items = items
    }
}

