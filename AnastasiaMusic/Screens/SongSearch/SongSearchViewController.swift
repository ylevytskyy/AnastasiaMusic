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

class SongSearchViewController: UIViewController {
    @IBOutlet weak var queryTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var viewModel: SongSearchViewModel!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = SongSearchViewModel(useCase: useCaseProvider().makeSongUseCase())

        let input = SongSearchViewModel.Input(
            queryTrigger: searchButton.rx.tap.withLatestFrom(queryTextField.rx.text).filter { $0 != nil }.map { $0! },
            listTrigger: listButton.rx.tap.asObservable(),
            downloadTrigger: tableView.rx.modelSelected(Song.self).asObservable())
        
        let output = viewModel.transform(input: input)
        
        output.searchResults
            .drive(tableView.rx.items(cellIdentifier: SongSearchTableCell.reuseId, cellType: SongSearchTableCell.self)) { _, value, cell in
                cell.textLabel?.text = value.description
            }
            .disposed(by: disposeBag)
        
        output.isBusy
            .drive(onNext: { [weak self] isBusy in
                QL2("isBusy \(isBusy)")
                if isBusy {
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
                }
            })
            .disposed(by: disposeBag)
        output.isBusy.map { !$0 }.drive(searchButton.rx.isEnabled).disposed(by: disposeBag)
        output.isBusy.map { !$0 }.drive(listButton.rx.isEnabled).disposed(by: disposeBag)
        
        output.navigateToListTrigger
            .drive(onNext: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.performSegue(withIdentifier: "playSegueue", sender: strongSelf)
            })
            .disposed(by: disposeBag)
    }
}
