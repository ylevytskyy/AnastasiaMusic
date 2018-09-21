//
//  Driver+Extensions.swift
//  Common
//
//  Created by Yuriy Levytskyy on 9/21/18.
//  Copyright © 2018 Yuriy Levytskyy. All rights reserved.
//

import RxSwift
import RxCocoa

extension Observable {
    public func asVoid() -> Observable<Void> {
        return map { _ in }
    }
}
