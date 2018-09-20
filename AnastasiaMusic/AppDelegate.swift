//
//  AppDelegate.swift
//  AnastasiaMusic
//
//  Created by Yuriy Levytskyy on 8/13/18.
//  Copyright © 2018 Yuriy Levytskyy. All rights reserved.
//

import UIKit
import QorumLogs
import Domain
import Platform

func useCaseProvider() -> Domain.UseCaseProvider {
    return (UIApplication.shared.delegate as! AppDelegate).useCaseProvider
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    public let useCaseProvider = Platform.UseCaseProvider()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        QorumLogs.enabled = true
        
        return true
    }
}
