//
//  SQLiteStack.swift
//  Platform
//
//  Created by Yuriy Levytskyy on 9/20/18.
//  Copyright © 2018 Yuriy Levytskyy. All rights reserved.
//

import QorumLogs
import FMDB

final class SQLiteStack {
    private let dbFileName = "db.sqlite3"
    
    public let dbQueue: FMDatabaseQueue
    
    public init() {
        let documentsPath = FileManager.default.documentDirectory() as NSString
        let fullPath = documentsPath.appendingPathComponent(dbFileName)
        QL1("SQLiteStack db path: \(fullPath)")
        dbQueue = FMDatabaseQueue(path: fullPath)
    }
}
