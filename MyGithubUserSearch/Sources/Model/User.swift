//
//  User.swift
//  MyGithubUserSearch
//
//  Created by Jinwoo Kim on 06/05/2019.
//  Copyright © 2019 jinuman. All rights reserved.
//

import Foundation
import RxDataSources

struct User: Decodable {
    var userItems: [UserItem]
    
    enum CodingKeys: String, CodingKey {
        case userItems = "items"
    }
}

extension User: SectionModelType {
    var items: [UserItem] {
        return self.userItems
    }
    
    init(original: User, items: [UserItem]) {
        self = original
        self.userItems = items
    }
}

struct UserItem: Decodable, Equatable {
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
