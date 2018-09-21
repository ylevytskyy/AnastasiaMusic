//
//  UseCaseProvider.swift
//  AnastasiaMusic
//
//  Created by Yuriy Levytskyy on 9/20/18.
//  Copyright © 2018 Yuriy Levytskyy. All rights reserved.
//

import RxSwift

public protocol UseCaseProviderType {
    func makeSongUseCase() -> SongUseCaseType
}
