//
//  PlayerViewController.swift
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

class PlayerViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private var useCase: Domain.SongUseCase!
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        useCase = useCaseProvider().makeSongUseCase()

        useCase.songs
            .bind(to: tableView.rx.items(cellIdentifier: PlayerTableCell.reuseId, cellType: PlayerTableCell.self)) { _, value, cell in
                cell.musicUrl = value.localURL
            }
            .disposed(by: disposeBag)
    }
}
