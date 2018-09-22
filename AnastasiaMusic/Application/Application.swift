//
//  Application.swift
//  AnastasiaMusic
//
//  Created by Yuriy Levytskyy on 9/21/18.
//  Copyright © 2018 Yuriy Levytskyy. All rights reserved.
//

import QorumLogs
import Swinject
import RxSwift
import RxFlow
import Domain
import Platform

// MARK: -  Service Locator

func serviceLocator() -> Container {
    return Application.shared.container
}

// MARK: - Application

final class Application {
    static let shared = Application()
    
    private lazy var flow = SearchFlow()
    
    private let coordinator = Coordinator()
    
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
    }
    
    private init() {
        QorumLogs.enabled = true
    }
    
    func configureMainInterface(in window: UIWindow) {
        Flows.whenReady(flows: [flow]) {
            window.rootViewController = $0.first
        }
        
        coordinator.coordinate(flow: flow, withStepper: OneStepper(withSingleStep: SongStep.search))
    }
}
