
//
//  GithubService.swift
//  MyGithubUserSearch
//
//  Created by Jinwoo Kim on 06/05/2019.
//  Copyright © 2019 jinuman. All rights reserved.
//

import Foundation
import RxSwift

class GithubAPI {
    
    private let session = URLSession.shared
    
    enum GithubAPIError: Error {
        case responseError
    }
    
    func url(for query: String?, page: Int) -> URL? {
        guard
            let query = query,
            query.isEmpty == false else { return nil }
        return URL(string: "https://api.github.com/search/users?q=\(query)&page=\(page)")
    }
    
    func fetchUsers(with query: String?, page: Int) -> Observable<(repos: [UserItem], nextPage: Int?)> {
        // Review: [사용성] fetchUsers 를 실패하면 사용자에게 알려줘야 합니다.
        let emptyResult: ([UserItem], Int?) = ([], nil)
        guard let url = self.url(for: query, page: page) else { return .just(emptyResult) }
        print("Current URL: \(url.absoluteString)")
        
        return Observable.create { observer in
            let task = self.session.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print("session error: \(error.localizedDescription)")
                    observer.onError(error)
                    return
                }
                // Check response status code
                if
                    let statusCode = (response as? HTTPURLResponse)?.statusCode,
                    (statusCode < 200 || statusCode > 300) {
                    print("Server returned an error")
                    if statusCode == 403 {
                        print("Github API rate limit exceeded. Wait for 60 seconds and try again.")
                    }
                    observer.onError(GithubAPIError.responseError)
                    return
                }
                
                guard let data = data else { return }
                
                do {
                    let user = try JSONDecoder().decode(User.self, from: data)
                    let nextPage = user.userItems.isEmpty
                        ? nil
                        : page + 1
                    print("userItems: \(user.userItems.count), nextPage: \(nextPage ?? -1)")
                    observer.onNext((user.userItems, nextPage))
                    
                } catch let jsonError {
                    observer.onError(jsonError)
                }
                observer.onCompleted()
            }
            task.resume()
            
            return Disposables.create { task.cancel() }
            }.catchErrorJustReturn(emptyResult)
    }
    
    func fetchOrganizations(with urlString: String?) -> Observable<[OrganizationItem]> {
        guard
            let urlString = urlString,
            let url = URL(string: urlString) else {
                // Review: [기본] 에러 처리 확실히 해야합니다.
                return .just([])
        }
        
        return Observable.create { observer in
            let task = self.session.dataTask(with: url) { (data, res, err) in
                if let err = err {
                    print("session error: \(err.localizedDescription)")
                    observer.onError(err)
                    return
                }
                
                guard let data = data else { return }
                
                do {
                    let organizations = try JSONDecoder().decode([OrganizationItem].self, from: data)
                    print("Found organizations: \(organizations.count)")
                    observer.onNext(organizations)
                    
                } catch let jsonError {
                    observer.onError(jsonError)
                }
                observer.onCompleted()
                
            }
            task.resume()
            
            return Disposables.create { task.cancel() }
            }
            .catchErrorJustReturn([])
    }
}
