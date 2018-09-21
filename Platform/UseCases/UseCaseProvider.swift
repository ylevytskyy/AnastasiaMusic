//
//  UseCaseProvider.swift
//  Platform
//
//  Created by Yuriy Levytskyy on 9/20/18.
//  Copyright © 2018 Yuriy Levytskyy. All rights reserved.
//

import RxSwift
import Domain

public class UseCaseProvider: Domain.UseCaseProviderType {
    private let sqliteStack = SQLiteStack()
    private let repository: Repository<Domain.Song>
    
    public init() {
        self.repository = Repository<Domain.Song>(dbQueue: sqliteStack.dbQueue)
    }
    
    public func makeSongUseCase() -> Domain.SongUseCaseType {
        return SongUseCase(repository: repository)
    }
}
