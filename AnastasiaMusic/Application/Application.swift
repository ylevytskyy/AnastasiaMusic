//
//  Application.swift
//  AnastasiaMusic
//
//  Created by Yuriy Levytskyy on 9/21/18.
//  Copyright © 2018 Yuriy Levytskyy. All rights reserved.
//

import QorumLogs
import Swinject
import Domain
import Platform

// MARK: -  Service Locator

func serviceLocator() -> Container {
    return Application.shared.container
}

// MARK: - Application

final class Application {
    static let shared = Application()
    
    let container = Container() { container in
        // UseCaseProvider
        container.register(UseCaseProviderType.self) { _ in
            Platform.UseCaseProvider()
        }.inObjectScope(.container)
        // SongUseCaseType
        container.register(SongUseCaseType.self) { resolver in
            let useCaseProvider = resolver.resolve(UseCaseProviderType.self)!
            return useCaseProvider.makeSongUseCase()
        }.inObjectScope(.container)
        // NavigatorType
        container.register(NavigatorType.self) { resolver in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let navigationController = UINavigationController()
            return Navigator(navigationController: navigationController, storyBoard: storyboard)
        }.inObjectScope(.container)
    }
    
    private init() {
        QorumLogs.enabled = true
    }
    
    func configureMainInterface(in window: UIWindow) {
        let navigator = serviceLocator().resolve(NavigatorType.self)!
        window.rootViewController = navigator.navigationController
        navigator.toSearchSongs()
    }
}
