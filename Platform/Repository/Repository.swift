//
//  Repository.swift
//  Platform
//
//  Created by Yuriy Levytskyy on 9/20/18.
//  Copyright © 2018 Yuriy Levytskyy. All rights reserved.
//

import FMDB
import RxSwift
import RxCocoa

final class Repository<T> where T: StorableType {
    public let entities: Observable<[T]>
    private let entitiesRelay = BehaviorRelay(value: [T]())
    
    private let dbQueue: FMDatabaseQueue
    
    init(dbQueue: FMDatabaseQueue) {
        self.dbQueue = dbQueue
        self.entities = entitiesRelay.asObservable()
        
        _ = self.createTable()
            .observeOn(MainScheduler.instance)
            .flatMap { _ in self.update() }
            .subscribe()
    }
    
    public func insert(entity: T) -> Observable<Void> {
        return Single<Void>.create { observable in
            self.dbQueue.inTransaction { db, _ in
                do {
                    let values = T.sqlColumnNames.map { entity.sqlValue(column: $0) }
                    let placeholders = values.reduce("") { a, _ in a.isEmpty ? "?" : "\(a), ?"}
                    try db.executeUpdate("INSERT OR REPLACE INTO \(T.sqlTableName) VALUES (\(placeholders))", values: values as [Any])
                    
                    observable(.success(()))
                    
                    _ = self
                        .update()
                        .subscribeOn(MainScheduler.instance)
                        .subscribe()
                }
                catch let error {
                    observable(.error(error))
                }
            }
            return Disposables.create {}
        }.asObservable()
    }
    
    public func update() -> Observable<Void> {
        return Single<Void>.create { observable in
            self.dbQueue.inDatabase { db in
                do {
                    let sqlString = "SELECT \(T.sqlColumnNames.joined(separator: ", ")) FROM \(T.sqlTableName)"
                    let resultSet = try db.executeQuery(sqlString, values: nil)
                    var entities = [T]()
                    while resultSet.next() {
                        let entity = T(resultSet: resultSet)
                        entities.append(entity)
                    }
                    
                    self.entitiesRelay.accept(entities)
                    observable(.success(()))
                }
                catch let error {
                    observable(.error(error))
                }
            }
            return Disposables.create {}
        }.asObservable()
    }
    
    public func query(description: String) -> Observable<[T]> {
        return Single<[T]>.create { observable in
            self.dbQueue.inDatabase { db in
                do {
                    let sqlString = "SELECT \(T.sqlColumnNames.joined(separator: ", ")) FROM \(T.sqlTableName) WHERE description=?"
                    let resultSet = try db.executeQuery(sqlString, values: [description])
                    var entities = [T]()
                    while resultSet.next() {
                        let entity = T(resultSet: resultSet)
                        entities.append(entity)
                    }
                    
                    observable(.success((entities)))
                }
                catch let error {
                    observable(.error(error))
                }
            }
            return Disposables.create {}
            }.asObservable()
    }
    
    private func createTable() -> Observable<Void> {
        return Single<Void>.create { observable in
            self.dbQueue.inDatabase { db in
                let sqlCreateFields = zip(T.sqlColumnNames, T.sqlColumnDescriptions).map { "\($0) \($1)" }.joined(separator: ", ")
                let query = "CREATE TABLE IF NOT EXISTS \(T.sqlTableName) (\(sqlCreateFields))"
                do {
                    try db.executeUpdate(query, values: nil)
                    observable(.success(()))
                }
                catch let error {
                    observable(.error(error))
                }
            }
            return Disposables.create {}
        }.asObservable()
    }
}
