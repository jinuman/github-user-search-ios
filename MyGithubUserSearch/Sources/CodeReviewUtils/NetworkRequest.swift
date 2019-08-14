//
//  NetworkRequest.swift
//  MyGithubUserSearch
//
//  Created by tskim on 14/08/2019.
//  Copyright © 2019 jinuman. All rights reserved.
//

import Foundation
import RxSwift

protocol NetworkRequest: class {
    func fetchUsers(with query: String?, page: Int) -> Observable<(repos: [UserItem], nextPage: Int?)>
    func fetchOrganizations(with urlString: String?) -> Observable<[OrganizationItem]>
}
