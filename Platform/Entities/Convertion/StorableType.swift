//
//  Storable.swift
//  Platform
//
//  Created by Yuriy Levytskyy on 9/20/18.
//  Copyright © 2018 Yuriy Levytskyy. All rights reserved.
//

import FMDB

// MARK: - StorableType

/// Enable storing model in SQLite DB
protocol StorableType {
    /// SQL table name
    static var sqlTableName: String { get }
    /// List of column descriptions for SQL CREATE command
    static var sqlColumnDescriptions: [String] { get }
    /// List of column names
    static var sqlColumnNames: [String] { get }
    
    /// Create from DB result
    init(resultSet: FMResultSet)

    /// Column value
    func sqlValue(column: String) -> Any?
}
