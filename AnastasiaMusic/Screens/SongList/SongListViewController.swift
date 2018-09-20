//
//  SongListViewController.swift
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

class SongListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private var useCase: Domain.SongUseCase!
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        useCase = useCaseProvider().makeSongUseCase()

        useCase.songs
            .bind(to: tableView.rx.items(cellIdentifier: SongListTableCell.reuseId, cellType: SongListTableCell.self)) { _, value, cell in
                cell.configure(song: value, useCase: self.useCase)
            }
            .disposed(by: disposeBag)
    }
}
