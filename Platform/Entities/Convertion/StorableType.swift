//
//  Storable.swift
//  Platform
//
//  Created by Yuriy Levytskyy on 9/20/18.
//  Copyright © 2018 Yuriy Levytskyy. All rights reserved.
//

import FMDB

protocol StorableType {
    static var sqlTableName: String { get }
    static var sqlColumnDescriptions: [String] { get }
    static var sqlColumnNames: [String] { get }
    
    init(resultSet: FMResultSet)

    func sqlValue(column: String) -> Any?
}
