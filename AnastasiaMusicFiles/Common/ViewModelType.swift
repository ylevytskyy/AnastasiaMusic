//
//  ViewModelType.swift
//  AnastasiaMusic
//
//  Created by Yuriy Levytskyy on 9/20/18.
//  Copyright © 2018 Yuriy Levytskyy. All rights reserved.
//

import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
