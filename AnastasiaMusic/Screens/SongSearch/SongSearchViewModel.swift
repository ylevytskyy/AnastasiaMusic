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
        let queryTrigger: Observable<String>
        let listTrigger: Observable<Void>
        let downloadTrigger: Observable<Domain.Song>
    }
    
    struct Output {
        let searchResults: Driver<[Song]>
        let isBusy: Driver<Bool>
        let navigateToListTrigger: Driver<Void>
    }
    
    private let useCase: Domain.SongUseCase
    
    private let isBusyRelay = BehaviorRelay(value: false)
    
    init(useCase: Domain.SongUseCase) {
        self.useCase = useCase
    }
    
    func transform(input: Input) -> Output {
        // Search trigger
        let searchEnabler = Observable.combineLatest(input.queryTrigger, isBusyRelay)
        let searchResults = input.queryTrigger
            .withLatestFrom(searchEnabler)
            .filter { !$0.1 }
            .map { $0.0 }
            .flatMap {
                self.useCase
                    .search(query: $0)
                    .do(onError: { _ in self.isBusyRelay.accept(false) }, onCompleted: { self.isBusyRelay.accept(false) }, onSubscribe: { self.isBusyRelay.accept(true) })
            }
            .asDriver(onErrorJustReturn: [Song]())
        
        // Download trigger
        let downloadedEnabler = Observable.combineLatest(input.downloadTrigger, isBusyRelay)
        let downloadedTrigger = input.downloadTrigger
            .withLatestFrom(downloadedEnabler)
            .filter { !$0.1 }
            .map { $0.0 }
            .flatMap {
                self.useCase
                    .download(song: $0)
                    .do(onError: { _ in self.isBusyRelay.accept(false) }, onCompleted: { self.isBusyRelay.accept(false) }, onSubscribe: { self.isBusyRelay.accept(true) })
        }
        
        // Navigate to List trigger
        let navigateToListTrigger = Observable<Void>
            .merge(input.listTrigger, downloadedTrigger)
            .asDriver(onErrorJustReturn: ())
        
        // Output
        return Output(
            searchResults:searchResults,
            isBusy: isBusyRelay.asDriver(),
            navigateToListTrigger:navigateToListTrigger)
    }
}
