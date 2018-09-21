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
    
    let useCaseProvider: Domain.UseCaseProviderType
    
    private init() {
        QorumLogs.enabled = true
        
        self.useCaseProvider = Platform.UseCaseProvider()
    }
    
    func configureMainInterface(in window: UIWindow) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        window.rootViewController = storyboard.instantiateViewController(withIdentifier: DocumentBrowserViewController.storyboardId)
    }
}
