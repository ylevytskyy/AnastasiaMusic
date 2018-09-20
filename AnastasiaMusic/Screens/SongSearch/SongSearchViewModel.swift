//
//  SongSearchViewModel.swift
//  AnastasiaMusic
//
//  Created by Yuriy Levytskyy on 9/20/18.
//  Copyright © 2018 Yuriy Levytskyy. All rights reserved.
//

import RxSwift
import RxCocoa
import Domain

final class SongSearchViewModel: ViewModelType {
    struct Input {
        let queryTrigger: Driver<String>
        let listTrigger: Driver<Void>
        let downloadTrigger: Driver<Domain.Song>
    }
    
    struct Output {
        let searchResults: Driver<[Song]>
        let isBusy: Driver<Bool>
        let navigateToListTrigger: Driver<Void>
        let downloadErrorTrigger: Driver<String>
    }
    
    private let useCase: Domain.SongUseCase
    
    private let isBusyRelay = BehaviorRelay(value: false)
    private let downloadErrorTriggerRelay = BehaviorRelay(value: "")
    
    init(useCase: Domain.SongUseCase) {
        self.useCase = useCase
    }
    
    func transform(input: Input) -> Output {
        // Search trigger
        let searchEnabler = Driver.combineLatest(input.queryTrigger, isBusyRelay.asDriver())
        let searchResults = input.queryTrigger
            .withLatestFrom(searchEnabler)
            .filter { !$0.1 }
            .map { $0.0 }
            .flatMap {
                self.useCase
                    .search(query: $0)
                    .do(onError: { _ in self.isBusyRelay.accept(false) }, onCompleted: { self.isBusyRelay.accept(false) }, onSubscribe: { self.isBusyRelay.accept(true) })
                .asDriver(onErrorJustReturn: [Song]())
            }
//            .asDriver(onErrorJustReturn: [Song]())
        
        // Download trigger
        let downloadedEnabler = Driver.combineLatest(input.downloadTrigger, isBusyRelay.asDriver())
        let downloadedTrigger = input.downloadTrigger
            .withLatestFrom(downloadedEnabler)
            .filter { !$0.1 }
            .map { $0.0 }
            .flatMap { song in
                self.useCase
                    .query(description: song.description)
                    .asDriver(onErrorJustReturn: [Song]())
                    .flatMap { (sameSongs:[Song]) -> Driver<Void> in
                        if !sameSongs.isEmpty {
                            self.downloadErrorTriggerRelay.accept("Пісню вже закачано")
                        }
                        return sameSongs.isEmpty
                            ?
                                self.useCase
                                    .download(song: song)
                                    .do(
                                        onError: { error in
                                            self.isBusyRelay.accept(false)
                                            self.downloadErrorTriggerRelay.accept(error.localizedDescription)
                                    }, onCompleted: {
                                        self.isBusyRelay.accept(false)
                                    }, onSubscribe: {
                                        self.isBusyRelay.accept(true)
                                    })
                                    .asDriver(onErrorJustReturn: ())
                            :
                            Observable
                                .just(())
                                .asDriver(onErrorJustReturn: ())
                }
        }
        
        // Output
        return Output(
            searchResults:searchResults,
            isBusy: isBusyRelay.asDriver(),
            navigateToListTrigger:Driver<Void>.merge(input.listTrigger, downloadedTrigger),
            downloadErrorTrigger:downloadErrorTriggerRelay.asDriver())
    }
}
