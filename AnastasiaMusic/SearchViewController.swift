//
//  ViewController.swift
//  AnastasiaMusic
//
//  Created by Yuriy Levytskyy on 8/13/18.
//  Copyright © 2018 Yuriy Levytskyy. All rights reserved.
//

import UIKit
import SwiftSoup
import QorumLogs
import RxSwift
import RxCocoa
import Platform
import Domain

class SearchViewController: UIViewController {
    @IBOutlet weak var queryTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    private let songsRelay = BehaviorRelay(value: [Song]())
    private var useCase: Domain.SongUseCase!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rx.itemSelected
            .subscribe(onNext: { indexPath in
                _ = self.songsRelay.subscribe(onNext: { songs in
                    _ = self.useCase
                        .download(song: songs[indexPath.row])
                        .subscribe(onNext: { _ in self.performSegue(withIdentifier: "playSegueue", sender: self) })
                })
            }).disposed(by: disposeBag)
        
        songsRelay
            .bind(to: tableView.rx.items(cellIdentifier: "CellId", cellType: UITableViewCell.self)) { _, value, cell in
                cell.textLabel?.text = value.description
            }
            .disposed(by: disposeBag)
        
        useCase = useCaseProvider().makeSongUseCase()
    }
    
    @IBAction func listAction(_ sender: Any) {
        self.performSegue(withIdentifier: "playSegueue", sender: self)
    }
    
    @IBAction func searchAction(_ sender: Any) {
        guard let query = queryTextField.text, !query.isEmpty else { return }
        
        useCase
            .search(query: query)
            .bind(to: songsRelay)
            .disposed(by: disposeBag)
    }
}
