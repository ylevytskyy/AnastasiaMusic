//
//  SongListCellViewModel.swift
//  AnastasiaMusic
//
//  Created by Yuriy Levytskyy on 9/20/18.
//  Copyright © 2018 Yuriy Levytskyy. All rights reserved.
//

import RxSwift
import RxCocoa
import Domain

final class SongListCellViewModel: ViewModelType {
    struct Input {
        let song: Driver<Domain.Song>
        let playTrigger: Observable<Void>
        let stopTrigger: Observable<Void>
    }
    
    struct Output {
        let songTitle: Driver<String>
        let playButtonTitle: Driver<String>
    }
    
    public var useCase: Domain.SongUseCase!
    
    private let disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        input.stopTrigger
            .flatMap { self.useCase.stop() }
            .subscribe()
            .disposed(by: disposeBag)

        input.playTrigger
            .withLatestFrom(input.song)
            .flatMap { self.useCase.play(song: $0) }
            .subscribe()
            .disposed(by: disposeBag)
        
        let playButtonTitle = Observable
            .merge(input.playTrigger.map { _ in true }, input.stopTrigger.map { _ in false })
            .asDriver(onErrorJustReturn: false)
            .debug("isPlaying", trimOutput: false)
            .map { $0 ? "Playing" : "Play" }
        
        // Output
        return Output(
            songTitle: input.song.map { $0.description },
            playButtonTitle: playButtonTitle)
    }
}
