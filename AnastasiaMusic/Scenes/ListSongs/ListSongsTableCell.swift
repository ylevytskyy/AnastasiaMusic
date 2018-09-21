//
//  ListSongsTableCell.swift
//  AnastasiaMusic
//
//  Created by Yuriy Levytskyy on 8/22/18.
//  Copyright © 2018 Yuriy Levytskyy. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture
import Domain
import QorumLogs

// MARK: - ListSongsTableCell

class ListSongsTableCell: UITableViewCell {
    public static let reuseId = "CellId"
    
    private let viewModel = ListSongsCellViewModel()
    private let songRelay = BehaviorRelay<Domain.Song?>(value: nil)
    private let disposableBag = DisposeBag()
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var songTitleLabel: UILabel!
}

// MARK: - UITableViewCell

extension ListSongsTableCell {
    override func awakeFromNib() {
        let input = ListSongsCellViewModel.Input(
            song: songRelay.filter { $0 != nil }.map { $0! }.asDriver(onErrorDriveWith: Driver<Song>.empty()),
            playTrigger: playButton.rx.tap.asDriver(),
            stopTrigger: stopButton.rx.tap.asDriver(),
            deleteTrigger: rx.longPressGesture().asDriver().map { _ in })
        
        let output = viewModel.transform(input: input)
        
        output.songTitle.drive(songTitleLabel.rx.text).disposed(by: disposableBag)
        output.playButtonTitle.drive(playButton.rx.title(for: .normal)).disposed(by: disposableBag)
    }
}

// MARK: - Implementation

extension ListSongsTableCell {
    func configure(state: Domain.Song) {
        songRelay.accept(state)
    }
}
