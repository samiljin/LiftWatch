//
//  AppDelegate.swift
//  LiftWatch
//
//  Created by Sami Iljin on 04/05/2018.
//  Copyright © 2018 Sami Iljin. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
    
        if AccessRights.isAllGiven {
            window?.rootViewController = TutorialVC()
        } else {
            window?.rootViewController = AccessRightsVC()
        }
        
        window?.backgroundColor = UIColor.white
        window?.makeKeyAndVisible()

        return true
    }

}

