//
//  AppDelegate.swift
//  MyGithubUserSearch
//
//  Created by Jinwoo Kim on 05/05/2019.
//  Copyright © 2019 jinuman. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = .white
        window.makeKeyAndVisible()
        
        let userSearchViewController = UserSearchViewController()
        userSearchViewController.reactor = UserSearchReactor()
        
        let navigationController = UINavigationController(
            rootViewController: userSearchViewController)
        
        window.rootViewController = navigationController
        
        self.window = window
        
        return true
    }

}
