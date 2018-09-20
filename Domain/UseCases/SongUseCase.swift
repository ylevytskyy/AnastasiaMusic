//
//  SongUseCase.swift
//  AnastasiaMusic
//
//  Created by Yuriy Levytskyy on 9/20/18.
//  Copyright © 2018 Yuriy Levytskyy. All rights reserved.
//

import RxSwift

public protocol SongUseCase {
    var songs: Observable<[Song]> { get }
    
    func search(query: String) -> Observable<[Song]>
    func download(song: Song) -> Observable<Void>
    
    func play(song: Song) -> Observable<Void>
    func stop() -> Observable<Void>
}
