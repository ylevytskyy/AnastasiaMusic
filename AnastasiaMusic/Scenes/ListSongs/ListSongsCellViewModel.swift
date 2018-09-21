//
//  ListSongsCellViewModel.swift
//  AnastasiaMusic
//
//  Created by Yuriy Levytskyy on 9/20/18.
//  Copyright © 2018 Yuriy Levytskyy. All rights reserved.
//

import RxSwift
import RxCocoa
import Domain

// MARK; - ListSongsCellViewModel

final class ListSongsCellViewModel {
    private let disposeBag = DisposeBag()
}

// MARK: - ViewModelType

extension ListSongsCellViewModel: ViewModelType {
    struct Input {
        let song: Driver<Domain.Song>
        let playTrigger: Driver<Void>
        let stopTrigger: Driver<Void>
        let deleteTrigger: Driver<Void>
    }
    
    struct Output {
        let songTitle: Driver<String>
        let playButtonTitle: Driver<String>
    }
    
    func transform(input: Input) -> Output {
        let useCase = serviceLocator().resolve(SongUseCaseType.self)!
        
        input.stopTrigger
            .flatMap { _ in useCase.stop().asDriver(onErrorJustReturn: ()) }
            .drive()
            .disposed(by: disposeBag)

        input.playTrigger
            .withLatestFrom(input.song)
            .flatMap { useCase.play(song: $0).asDriver(onErrorJustReturn: ()) }
            .drive()
            .disposed(by: disposeBag)
        
        let playButtonTitle = Driver
            .merge(input.playTrigger.map { _ in true }, input.stopTrigger.map { _ in false })
            .map { $0 ? "Грається" : "Грати" }
        
        input.deleteTrigger
            .withLatestFrom(input.song)
            .asObservable()
            .flatMap { useCase.delete(song: $0) }
            .subscribe()
            .disposed(by: disposeBag)
        
        return Output(
            songTitle: input.song.map { $0.description },
            playButtonTitle: playButtonTitle)
    }
}
