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
    private let disposeBag = DisposeBag()
    
    private let isBusyRelay = BehaviorRelay(value: false)
    private let downloadErrorTriggerRelay = BehaviorRelay(value: "")
    private let navigateToListTriggerRelay = PublishRelay<Song?>()
}

// MARK: - ViewModelType

extension SearchSongsViewModel: ViewModelType {
    struct Input {
        let queryTrigger: Driver<String>
        let listTrigger: Driver<Void>
        let downloadTrigger: Driver<Domain.Song>
    }
    
    struct Output {
        let searchResults: Driver<[Song]>
        let isBusy: Driver<Bool>
        let downloadErrorTrigger: Driver<String>
        let navigateTrigger: Driver<Song?>
    }

    func transform(input: Input) -> Output {
        let useCase = serviceLocator().resolve(SongUseCaseType.self)!
        
        // Search trigger
        let searchEnabler = Driver.combineLatest(input.queryTrigger, isBusyRelay.asDriver())
        let searchResults = input.queryTrigger
            .withLatestFrom(searchEnabler)
            .filter { !$0.1 }
            .map { $0.0 }
            .flatMap {
                useCase
                    .search(query: $0)
                    .do(onError: { _ in self.isBusyRelay.accept(false) },
                        onCompleted: { self.isBusyRelay.accept(false) },
                        onSubscribe: { self.isBusyRelay.accept(true) })
                .asDriver(onErrorJustReturn: [Song]())
            }
        
        // Download trigger
        let downloadedEnabler = Driver.combineLatest(input.downloadTrigger, isBusyRelay.asDriver())
        let downloadedTrigger = input.downloadTrigger
            .withLatestFrom(downloadedEnabler)
            .filter { !$0.1 }
            .map { $0.0 }
            .flatMap { song in
                // Prevent downloading same song twice
                useCase
                    .query(description: song.description)
                    .asDriver(onErrorJustReturn: [Song]())
                    .flatMap { (sameSongs:[Song]) -> Driver<Bool> in
                        if !sameSongs.isEmpty {
                            self.downloadErrorTriggerRelay.accept("Пісню вже закачано")
                        }
                        return sameSongs.isEmpty
                            ?
                                // Download new song
                                useCase
                                    .download(song: song)
                                    .do(onError: { error in
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
                                // Song already downloaded
                            Observable<Bool>
                                .just(false)
                                .asDriver(onErrorJustReturn: false)
                    }
                    .filter { $0 }
                    .map { _ in song as Song? }
        }
        
        // Navigation
//        Driver<Song?>.merge(input.listTrigger.map { _ in nil }, downloadedTrigger)
//            .drive(onNext: {
//                let navigator = serviceLocator().resolve(NavigatorType.self)!
//                navigator.toListSongs(selectedSong: $0)
//            })
//            .disposed(by: disposeBag)
        Driver<Song?>
            .merge(input.listTrigger.map { _ in nil }, downloadedTrigger)
            .asObservable()
            .bind(to: navigateToListTriggerRelay)
            .disposed(by: disposeBag)
        
        let navigateTrigger = Driver<Song?>.merge(input.listTrigger.map { _ in nil }, downloadedTrigger)
        // Output
        return Output(
            searchResults:searchResults,
            isBusy: isBusyRelay.asDriver(),
            downloadErrorTrigger:downloadErrorTriggerRelay.asDriver(),
            navigateTrigger: navigateTrigger)
    }
}
