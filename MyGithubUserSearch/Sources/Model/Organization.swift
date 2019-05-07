//
//  Organization.swift
//  MyGithubUserSearch
//
//  Created by Jinwoo Kim on 07/05/2019.
//  Copyright © 2019 jinuman. All rights reserved.
//

import Foundation

struct Organization: Decodable {
    let avatarUrl: String
    
    enum CodingKeys: String, CodingKey {
        case avatarUrl = "avatar_url"
    }
}
