//
//  SearchSongsViewModel.swift
//  AnastasiaMusic
//
//  Created by Yuriy Levytskyy on 9/20/18.
//  Copyright © 2018 Yuriy Levytskyy. All rights reserved.
//

import RxSwift
import RxCocoa
import Common
import Domain

// MARK: - SearchSongsViewModel

final class SearchSongsViewModel {
    private let useCase: Domain.SongUseCase
    private let navigator: NavigatorType
    private let disposeBag = DisposeBag()
    
    private let isBusyRelay = BehaviorRelay(value: false)
    private let downloadErrorTriggerRelay = BehaviorRelay(value: "")
    
    init(useCase: Domain.SongUseCase, navigator: NavigatorType) {
        self.useCase = useCase
        self.navigator = navigator
    }
    
    struct Input {
        let queryTrigger: Driver<String>
        let listTrigger: Driver<Void>
        let downloadTrigger: Driver<Domain.Song>
    }
    
    struct Output {
        let searchResults: Driver<[Song]>
        let isBusy: Driver<Bool>
        let downloadErrorTrigger: Driver<String>
    }
}

extension SearchSongsViewModel: ViewModelType {
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
                    .flatMap { (sameSongs:[Song]) -> Driver<Bool> in
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
                                    . map { _ in true }
                                    .asDriver(onErrorJustReturn: false)
                            :
                            Observable<Bool>
                                .just(false)
                                .asDriver(onErrorJustReturn: false)
                    }
                    .filter { $0 }
                    .map { _ in }
        }
        
        // Navigation
        Driver<Void>.merge(input.listTrigger, downloadedTrigger)
            .drive(onNext: { _ in self.navigator.toListSongs() })
            .disposed(by: disposeBag)
        
        // Output
        return Output(
            searchResults:searchResults,
            isBusy: isBusyRelay.asDriver(),
            downloadErrorTrigger:downloadErrorTriggerRelay.asDriver())
    }
}
