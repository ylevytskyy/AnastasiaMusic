//
//  ListSongsViewController.swift
//  AnastasiaMusic
//
//  Created by Yuriy Levytskyy on 8/22/18.
//  Copyright © 2018 Yuriy Levytskyy. All rights reserved.
//

import UIKit
import QorumLogs
import RxSwift
import Domain
import Platform

// MARK: - ListSongsViewController

class ListSongsViewController: UIViewController {
    static let storyboardId = "ListSongsViewController"
    
    var useCase: Domain.SongUseCase!
    
    private let disposeBag = DisposeBag()

    @IBOutlet weak var tableView: UITableView!
}

// MARK: - UIViewController

extension ListSongsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        useCase.songs
            .bind(to: tableView.rx.items(cellIdentifier: ListSongsTableCell.reuseId, cellType: ListSongsTableCell.self)) { _, value, cell in
                cell.configure(state: value, useCase: self.useCase)
            }
            .disposed(by: disposeBag)
    }
}
