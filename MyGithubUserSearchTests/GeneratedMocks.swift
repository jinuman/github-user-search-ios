// MARK: - Mocks generated from file: MyGithubUserSearch/Sources/CodeReviewUtils/NetworkRequest.swift at 2019-08-14 00:55:54 +0000

//
//  NetworkRequest.swift
//  MyGithubUserSearch
//
//  Created by tskim on 14/08/2019.
//  Copyright © 2019 jinuman. All rights reserved.
//

import Cuckoo
@testable import MyGithubUserSearch

import Foundation
import RxSwift


 class MockNetworkRequest: NetworkRequest, Cuckoo.ProtocolMock {
    
     typealias MocksType = NetworkRequest
    
     typealias Stubbing = __StubbingProxy_NetworkRequest
     typealias Verification = __VerificationProxy_NetworkRequest

     let cuckoo_manager = Cuckoo.MockManager.preconfiguredManager ?? Cuckoo.MockManager(hasParent: false)

    
    private var __defaultImplStub: NetworkRequest?

     func enableDefaultImplementation(_ stub: NetworkRequest) {
        __defaultImplStub = stub
        cuckoo_manager.enableDefaultStubImplementation()
    }
    

    

    

    
    
    
     func fetchUsers(with query: String?, page: Int) -> Observable<(repos: [UserItem], nextPage: Int?)> {
        
    return cuckoo_manager.call("fetchUsers(with: String?, page: Int) -> Observable<(repos: [UserItem], nextPage: Int?)>",
            parameters: (query, page),
            escapingParameters: (query, page),
            superclassCall:
                
                Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                ,
            defaultCall: __defaultImplStub!.fetchUsers(with: query, page: page))
        
    }
    
    
    
     func fetchOrganizations(with urlString: String?) -> Observable<[OrganizationItem]> {
        
    return cuckoo_manager.call("fetchOrganizations(with: String?) -> Observable<[OrganizationItem]>",
            parameters: (urlString),
            escapingParameters: (urlString),
            superclassCall:
                
                Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                ,
            defaultCall: __defaultImplStub!.fetchOrganizations(with: urlString))
        
    }
    

	 struct __StubbingProxy_NetworkRequest: Cuckoo.StubbingProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	
	     init(manager: Cuckoo.MockManager) {
	        self.cuckoo_manager = manager
	    }
	    
	    
	    func fetchUsers<M1: Cuckoo.OptionalMatchable, M2: Cuckoo.Matchable>(with query: M1, page: M2) -> Cuckoo.ProtocolStubFunction<(String?, Int), Observable<(repos: [UserItem], nextPage: Int?)>> where M1.OptionalMatchedType == String, M2.MatchedType == Int {
	        let matchers: [Cuckoo.ParameterMatcher<(String?, Int)>] = [wrap(matchable: query) { $0.0 }, wrap(matchable: page) { $0.1 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockNetworkRequest.self, method: "fetchUsers(with: String?, page: Int) -> Observable<(repos: [UserItem], nextPage: Int?)>", parameterMatchers: matchers))
	    }
	    
	    func fetchOrganizations<M1: Cuckoo.OptionalMatchable>(with urlString: M1) -> Cuckoo.ProtocolStubFunction<(String?), Observable<[OrganizationItem]>> where M1.OptionalMatchedType == String {
	        let matchers: [Cuckoo.ParameterMatcher<(String?)>] = [wrap(matchable: urlString) { $0 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockNetworkRequest.self, method: "fetchOrganizations(with: String?) -> Observable<[OrganizationItem]>", parameterMatchers: matchers))
	    }
	    
	}

	 struct __VerificationProxy_NetworkRequest: Cuckoo.VerificationProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	    private let callMatcher: Cuckoo.CallMatcher
	    private let sourceLocation: Cuckoo.SourceLocation
	
	     init(manager: Cuckoo.MockManager, callMatcher: Cuckoo.CallMatcher, sourceLocation: Cuckoo.SourceLocation) {
	        self.cuckoo_manager = manager
	        self.callMatcher = callMatcher
	        self.sourceLocation = sourceLocation
	    }
	
	    
	
	    
	    @discardableResult
	    func fetchUsers<M1: Cuckoo.OptionalMatchable, M2: Cuckoo.Matchable>(with query: M1, page: M2) -> Cuckoo.__DoNotUse<(String?, Int), Observable<(repos: [UserItem], nextPage: Int?)>> where M1.OptionalMatchedType == String, M2.MatchedType == Int {
	        let matchers: [Cuckoo.ParameterMatcher<(String?, Int)>] = [wrap(matchable: query) { $0.0 }, wrap(matchable: page) { $0.1 }]
	        return cuckoo_manager.verify("fetchUsers(with: String?, page: Int) -> Observable<(repos: [UserItem], nextPage: Int?)>", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func fetchOrganizations<M1: Cuckoo.OptionalMatchable>(with urlString: M1) -> Cuckoo.__DoNotUse<(String?), Observable<[OrganizationItem]>> where M1.OptionalMatchedType == String {
	        let matchers: [Cuckoo.ParameterMatcher<(String?)>] = [wrap(matchable: urlString) { $0 }]
	        return cuckoo_manager.verify("fetchOrganizations(with: String?) -> Observable<[OrganizationItem]>", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	}
}

 class NetworkRequestStub: NetworkRequest {
    

    

    
     func fetchUsers(with query: String?, page: Int) -> Observable<(repos: [UserItem], nextPage: Int?)>  {
        return DefaultValueRegistry.defaultValue(for: (Observable<(repos: [UserItem], nextPage: Int?)>).self)
    }
    
     func fetchOrganizations(with urlString: String?) -> Observable<[OrganizationItem]>  {
        return DefaultValueRegistry.defaultValue(for: (Observable<[OrganizationItem]>).self)
    }
    
}

