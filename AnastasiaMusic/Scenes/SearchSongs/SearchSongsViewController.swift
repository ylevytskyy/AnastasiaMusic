//
//  SearchSongsViewController.swift
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
import RxFlow
import Platform
import Domain

// MARK: - SearchSongsViewController

class SearchSongsViewController: UIViewController, Stepper {
    static let storyboardId = "SearchSongsViewController"
    
    private let stepsRelay = PublishRelay<Step>()
    var steps: Observable<Step> { return stepsRelay.asObservable() }
    
    private let viewModel = SearchSongsViewModel()
    
    private let disposeBag = DisposeBag()

    @IBOutlet weak var queryTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
}

// MARK: - UIViewController

extension SearchSongsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        // Inputs
        
        let queryTrigger = Driver
            .merge(queryTextField.rx.controlEvent(.editingDidEnd).asDriver(), searchButton.rx.tap.asDriver())
            .withLatestFrom(queryTextField.rx.text.asDriver())
            .filter { $0 != nil }
            .map { $0! }
        
        let input = SearchSongsViewModel.Input(
            queryTrigger: queryTrigger,
            listTrigger: listButton.rx.tap.asDriver(),
            downloadTrigger: tableView.rx.modelSelected(Song.self).asDriver())
        
        //
        // Outputs
        
        let output = viewModel.transform(input: input)
        
        // Search result
        output.searchResults
            .drive(tableView.rx.items(cellIdentifier: SearchSongsTableCell.reuseId, cellType: SearchSongsTableCell.self)) { _, state, cell in
                cell.configure(state: state)
            }
            .disposed(by: disposeBag)
        
        // Is Busy indicator
        output.isBusy
            .drive(onNext: { [weak self] isBusy in
                if isBusy {
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
                }
            })
            .disposed(by: disposeBag)
        output.isBusy
            .map { !$0 }
            .drive(searchButton.rx.isEnabled)
            .disposed(by: disposeBag)
        output.isBusy
            .map { !$0 }
            .drive(listButton.rx.isEnabled)
            .disposed(by: disposeBag)
                
        // Download error
        output.downloadErrorTrigger
            .skip(1)
            .drive(onNext: { [weak self] message in
                let alertController = UIAlertController(title: "Не вдалось завантажити файл", message: message, preferredStyle: .alert)
                let action = UIAlertAction(title: "Гаразд", style: .default) { _ in }
                alertController.addAction(action)
                self?.present(alertController, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        // Navigation
        output.navigateTrigger
            .asObservable()
            .map { SongStep.list(song: $0) }
            .bind(to: stepsRelay)
            .disposed(by: disposeBag)
    }
}
