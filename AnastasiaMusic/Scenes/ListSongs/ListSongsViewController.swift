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
import RxCocoa
import Domain
import Platform

// MARK: - ListSongsViewController

class ListSongsViewController: UIViewController {
    static let storyboardId = "ListSongsViewController"
    
    let selectedSongRelay = BehaviorRelay<Song?>(value: nil)
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var tableView: UITableView!
}

// MARK: - UIViewController

extension ListSongsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let useCase = serviceLocator().resolve(SongUseCaseType.self)!
        useCase.songs
            .bind(to: tableView.rx.items(cellIdentifier: ListSongsTableCell.reuseId, cellType: ListSongsTableCell.self)) { _, value, cell in
                cell.configure(state: value)
            }
            .disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let useCase = serviceLocator().resolve(SongUseCaseType.self)!
        selectedSongRelay.asObservable()
            .filter { $0 != nil }
            .map { $0! }
            .flatMap { song in useCase.songs.map { $0.firstIndex(where: { $0.description == song.description }) } }
            .filter { $0 != nil }
            .map { $0! }
            .map { IndexPath(row: $0, section: 0) }
            .subscribe(onNext: { self.tableView.selectRow(at: $0, animated: true, scrollPosition: .middle) })
            .disposed(by: disposeBag)
    }
}
