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
        let playTrigger: Driver<Void>
        let stopTrigger: Driver<Void>
    }
    
    struct Output {
        let songTitle: Driver<String>
        let playButtonTitle: Driver<String>
    }
    
    public var useCase: Domain.SongUseCase!
    
    private let disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        input.stopTrigger
            .flatMap { _ in self.useCase.stop().asDriver(onErrorJustReturn: ()) }
            .drive()
            .disposed(by: disposeBag)

        input.playTrigger
            .withLatestFrom(input.song)
            .flatMap { self.useCase.play(song: $0).asDriver(onErrorJustReturn: ()) }
            .drive()
            .disposed(by: disposeBag)
        
        let playButtonTitle = Driver
            .merge(input.playTrigger.map { _ in true }, input.stopTrigger.map { _ in false })
            .map { $0 ? "Грається" : "Грати" }
        
        // Output
        return Output(
            songTitle: input.song.map { $0.description },
            playButtonTitle: playButtonTitle)
    }
}
