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
    var navigationController: UINavigationController { get }
    
    func toListSongs(selectedSong: Song?)
    func toSearchSongs()
}

// MARK: - Navigator

class Navigator {
    let navigationController: UINavigationController

    private let storyBoard: UIStoryboard
    
    init(navigationController: UINavigationController, storyBoard: UIStoryboard) {
        self.navigationController = navigationController
        self.storyBoard = storyBoard
    }
}

// MARK: - NavigatorType

extension Navigator: NavigatorType {
    func toListSongs(selectedSong: Song?) {
        guard let viewController = storyBoard.instantiateViewController(withIdentifier: ListSongsViewController.storyboardId) as? ListSongsViewController else { fatalError() }
        viewController.selectedSongRelay.accept(selectedSong)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func toSearchSongs() {
        guard let viewController = storyBoard.instantiateViewController(withIdentifier: SearchSongsViewController.storyboardId) as? SearchSongsViewController else { fatalError() }
        navigationController.pushViewController(viewController, animated: true)
    }
}
