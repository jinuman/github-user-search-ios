//
//  AppDelegate.swift
//  MyGithubUserSearch
//
//  Created by Jinwoo Kim on 05/05/2019.
//  Copyright © 2019 jinuman. All rights reserved.
//

import UIKit

import SwiftyBeaver

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
        -> Bool
    {
        logger.addDestination(ConsoleDestination())
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        let userSearchViewController = UserSearchViewController()
        userSearchViewController.reactor = UserSearchReactor()
        
        let navigationController = UINavigationController(
            rootViewController: userSearchViewController
        )
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        self.window = window
        
        return true
    }
    
}
