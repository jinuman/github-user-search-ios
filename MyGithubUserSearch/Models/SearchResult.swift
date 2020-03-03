//
//  SearchResult.swift
//  MyGithubUserSearch
//
//  Created by Jinwoo Kim on 06/05/2019.
//  Copyright © 2019 jinuman. All rights reserved.
//

import Foundation
import RxDataSources

extension SearchResult: SectionModelType {
    
    typealias Item = UserInfo
    
    init(original: SearchResult, items: [Item]) {
        self = original
        self.items = items
    }
}

struct SearchResult: Decodable {
    var items: [UserInfo]
}

struct UserInfo: Decodable {
    let username: String
    let score: Double
    let profileImageUrl: String
    let organizationsUrl: String
    
    enum CodingKeys: String, CodingKey {
        case username = "login"
        case score
        case profileImageUrl = "avatar_url"
        case organizationsUrl = "organizations_url"
    }
}
