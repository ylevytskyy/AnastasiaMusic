//
//  URL+Extensions.swift
//  Platform
//
//  Created by Yuriy Levytskyy on 9/20/18.
//  Copyright © 2018 Yuriy Levytskyy. All rights reserved.
//

import Foundation

public extension URL {
    public init?(optionalString: String?) {
        guard let optionalString = optionalString else { return nil}
        self.init(string: optionalString)
    }
}
