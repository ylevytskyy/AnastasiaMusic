//
//  Navigator.swift
//  AnastasiaMusic
//
//  Created by Yuriy Levytskyy on 9/21/18.
//  Copyright © 2018 Yuriy Levytskyy. All rights reserved.
//

import UIKit
import Common
import Domain
import Platform

// MARK: - NavigatorType

protocol NavigatorType {
    func toListSongs()
    func toSearchSongs()
}

// MARK: - Navigator

class Navigator {
    private let storyBoard: UIStoryboard
    private let navigationController: UINavigationController
    private let useCaseProvider: Domain.UseCaseProvider
    
    init(useCaseProvider: Domain.UseCaseProvider, navigationController: UINavigationController, storyBoard: UIStoryboard) {
        self.useCaseProvider = useCaseProvider
        self.navigationController = navigationController
        self.storyBoard = storyBoard
    }
}

// MARK: - NavigatorType

extension Navigator: NavigatorType {
    func toListSongs() {
        guard let viewController = storyBoard.instantiateViewController(withIdentifier: ListSongsViewController.storyboardId) as? ListSongsViewController else {
            fatalError()
        }
        viewController.useCase = useCaseProvider.makeSongUseCase()
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func toSearchSongs() {
        guard let viewController = storyBoard.instantiateViewController(withIdentifier: SearchSongsViewController.storyboardId) as? SearchSongsViewController else {
            fatalError()
        }
        viewController.viewModel = SearchSongsViewModel(useCase: useCaseProvider.makeSongUseCase(), navigator: self)
        navigationController.pushViewController(viewController, animated: true)
    }
}
