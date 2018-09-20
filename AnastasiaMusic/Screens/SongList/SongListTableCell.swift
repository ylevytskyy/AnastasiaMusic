//
//  SongListTableCell.swift
//  AnastasiaMusic
//
//  Created by Yuriy Levytskyy on 8/22/18.
//  Copyright © 2018 Yuriy Levytskyy. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Domain
import QorumLogs

class SongListTableCell: UITableViewCell {
    public static let reuseId = "CellId"
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var songTitleLabel: UILabel!

    private let viewModel = SongListCellViewModel()
    private let songRelay = BehaviorRelay<Domain.Song?>(value: nil)
    private let disposableBag = DisposeBag()
    
    override func awakeFromNib() {
        let input = SongListCellViewModel.Input(
            song: songRelay.filter { $0 != nil }.map { $0! }.asDriver(onErrorDriveWith: Driver<Song>.empty()),
            playTrigger: playButton.rx.tap.asObservable(),
            stopTrigger: stopButton.rx.tap.asObservable())
        
        let output = viewModel.transform(input: input)
        
        output.songTitle.drive(songTitleLabel.rx.text).disposed(by: disposableBag)
        output.playButtonTitle.drive(playButton.rx.title(for: .normal)).disposed(by: disposableBag)
    }
    
    func configure(state: Domain.Song, useCase: Domain.SongUseCase) {
        viewModel.useCase = useCase
        songRelay.accept(state)
    }
}
