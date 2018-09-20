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
        let searchResults = input.queryTrigger
            .flatMap {
                self.useCase
                    .search(query: $0)
                    .do(onError: { _ in self.isBusyRelay.accept(false) }, onCompleted: { self.isBusyRelay.accept(false) }, onSubscribe: { self.isBusyRelay.accept(true) })
            }
            .asDriver(onErrorJustReturn: [Song]())
        
        let downloadedTrigger = input.downloadTrigger
            .flatMap {
                self.useCase
                    .download(song: $0)
                    .do(onError: { _ in self.isBusyRelay.accept(false) }, onCompleted: { self.isBusyRelay.accept(false) }, onSubscribe: { self.isBusyRelay.accept(true) })
        }
        
        let navigateToListTrigger = Observable<Void>
            .merge(input.listTrigger, downloadedTrigger)
            .asDriver(onErrorJustReturn: ())
        
        return Output(
            searchResults:searchResults,
            isBusy: isBusyRelay.asDriver(),
            navigateToListTrigger:navigateToListTrigger)
    }
}
