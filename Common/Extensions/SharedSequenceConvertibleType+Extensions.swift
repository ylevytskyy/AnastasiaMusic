//
//  SharedSequenceConvertibleType+Extensions.swift
//  Common
//
//  Created by Yuriy Levytskyy on 9/21/18.
//  Copyright © 2018 Yuriy Levytskyy. All rights reserved.
//

import RxSwift
import RxCocoa

public extension SharedSequenceConvertibleType {
    public func asVoid() -> SharedSequence<SharingStrategy, Void> {
        return map { _ in }
    }
}
