//
//  main.swift
//  MyGithubUserSearch
//
//  Created by tskim on 14/08/2019.
//  Copyright © 2019 jinuman. All rights reserved.
//
import UIKit

private func appDelegateClassName() -> String {
    let isTesting = NSClassFromString("XCTestCase") != nil
    return isTesting ? "MyGithubUserSearchTests.TestAppDelegate" : NSStringFromClass(AppDelegate.self)
}

UIApplicationMain(
    CommandLine.argc,
    CommandLine.unsafeArgv,
    NSStringFromClass(UIApplication.self),
    appDelegateClassName()
)
