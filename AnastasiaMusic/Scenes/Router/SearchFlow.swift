//
//  SearchFlow.swift
//  AnastasiaMusic
//
//  Created by Yuriy Levytskyy on 9/21/18.
//  Copyright © 2018 Yuriy Levytskyy. All rights reserved.
//

import UIKit
import Common
import Domain
import Platform

import RxSwift
import RxFlow

enum SongStep : Step {
    case search
    case list(song: Song?)
}

class SearchFlow : Flow {
    var root: Presentable {
        return navigationController
    }
    
    private let storyBoard = UIStoryboard(name: "Main", bundle: nil)
    private let navigationController = UINavigationController()
    
    func navigate(to step: Step) -> NextFlowItems {
        guard let step = step as? SongStep else { return NextFlowItems.none }
        
        switch step {
        case .search:
            return navigateToSearchScreen()
        case .list(let song):
            return navigateToSongListScreen(selectedSong: song)
        }
    }
    
    private func navigateToSearchScreen () -> NextFlowItems {
        guard let searchSongsController = storyBoard.instantiateViewController(withIdentifier: SearchSongsViewController.storyboardId) as? SearchSongsViewController else { fatalError() }
        navigationController.pushViewController(searchSongsController, animated: true)
        return NextFlowItems.one(flowItem: NextFlowItem(nextPresentable: searchSongsController, nextStepper: searchSongsController))
        
    }
    
    private func navigateToSongListScreen (selectedSong: Song?) -> NextFlowItems {
        guard let listSongsController = storyBoard.instantiateViewController(withIdentifier: ListSongsViewController.storyboardId) as? ListSongsViewController else { fatalError() }
        listSongsController.selectedSongRelay.accept(selectedSong)
        navigationController.pushViewController(listSongsController, animated: true)
        return NextFlowItems.none
    }
}
