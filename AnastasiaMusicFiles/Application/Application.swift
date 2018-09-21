//
//  Application.swift
//  AnastasiaMusicFiles
//
//  Created by Yuriy Levytskyy on 9/21/18.
//  Copyright © 2018 Yuriy Levytskyy. All rights reserved.
//

import QorumLogs
import Domain
import Platform

final class Application {
    static let shared = Application()
    
    let useCaseProvider: Domain.UseCaseProvider
    
    private init() {
        QorumLogs.enabled = true
        
        self.useCaseProvider = Platform.UseCaseProvider()
    }
    
    func configureMainInterface(in window: UIWindow) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let navigationController = UINavigationController()
//        let navigator = Navigator(useCaseProvider: useCaseProvider, navigationController: navigationController, storyBoard: storyboard)
        window.rootViewController = storyboard.instantiateViewController(withIdentifier: DocumentBrowserViewController.storyboardId)
//        navigator.toSearchSongs()
    }
}
