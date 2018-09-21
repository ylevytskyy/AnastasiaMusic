//
//  ListSongsViewController.swift
//  AnastasiaMusic
//
//  Created by Yuriy Levytskyy on 8/22/18.
//  Copyright © 2018 Yuriy Levytskyy. All rights reserved.
//

import UIKit
import Swinject
import QorumLogs
import RxSwift
import Domain
import Platform

// MARK: - ListSongsViewController

class ListSongsViewController: UIViewController {
    static let storyboardId = "ListSongsViewController"
    
    @IBOutlet weak var tableView: UITableView!
}

// MARK: - UIViewController

extension ListSongsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let useCase = serviceLocator().resolve(SongUseCaseType.self)!
        _ = useCase.songs
            .bind(to: tableView.rx.items(cellIdentifier: ListSongsTableCell.reuseId, cellType: ListSongsTableCell.self)) { _, value, cell in
                cell.configure(state: value)
            }
    }
}
