//
//  AppDelegate.swift
//  KDTree
//
//  Created by Konrad Feiler on 03/28/2016.
//  Copyright (c) 2016 Konrad Feiler. All rights reserved.
//

import UIKit
import SwiftyBeaver

let log = SwiftyBeaver.self

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        let console = ConsoleDestination()  // log to Xcode Console
        console.minLevel = .debug
        log.addDestination(console)
        
        return true
    }

}

extension UINavigationController {
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .default
    }
}
