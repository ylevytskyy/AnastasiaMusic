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
    func toSearchSongs(_ importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void)
    func toHome()
}

// MARK: - Navigator

class Navigator {
    private let viewController: UIViewController
    private var presentedViewController: UIViewController?
    
    init(_ viewController: UIViewController) {
        self.viewController = viewController
    }
}

// MARK: - NavigatorType

extension Navigator: NavigatorType {
    func toSearchSongs(_ importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        guard let presentedViewController = storyBoard.instantiateViewController(withIdentifier: SearchSongsViewController.storyboardId) as? SearchSongsViewController else {
            fatalError()
        }
        presentedViewController.viewModel = SearchSongsViewModel(useCase: Application.shared.useCaseProvider.makeSongUseCase(), navigator: self, importHandler)
        
        self.viewController.present(presentedViewController, animated: true) {
            self.presentedViewController = presentedViewController
        }
    }
    
    func toHome() {
        presentedViewController?.dismiss(animated: true) {
            self.presentedViewController = nil
        }
    }
}
