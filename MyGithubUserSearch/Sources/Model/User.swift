//
//  User.swift
//  MyGithubUserSearch
//
//  Created by Jinwoo Kim on 06/05/2019.
//  Copyright © 2019 jinuman. All rights reserved.
//

import Foundation

struct User: Decodable {
    var userItems: [UserItem]
    
    enum CodingKeys: String, CodingKey {
        case userItems = "items"
    }
}

struct UserItem: Decodable {
    let username: String
    let score: Double
    let avatarUrl: String
    let organizationsUrl: String
    
    enum CodingKeys: String, CodingKey {
        case username = "login"
        case score
        case avatarUrl = "avatar_url"
        case organizationsUrl = "organizations_url"
    }
}
