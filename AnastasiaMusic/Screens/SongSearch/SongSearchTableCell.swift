//
//  SongSearchTableCell.swift
//  AnastasiaMusic
//
//  Created by Yuriy Levytskyy on 9/20/18.
//  Copyright © 2018 Yuriy Levytskyy. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Domain

class SongSearchTableCell: UITableViewCell {
    public static let reuseId = "CellId"
}

extension SongSearchTableCell {
    func configure(state: Song) {
        self.textLabel?.text = state.description
    }
}
