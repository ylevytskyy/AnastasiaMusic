//
//  SearchSongsTableCell.swift
//  AnastasiaMusic
//
//  Created by Yuriy Levytskyy on 9/20/18.
//  Copyright © 2018 Yuriy Levytskyy. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Domain

class SearchSongsTableCell: UITableViewCell {
    public static let reuseId = "CellId"
    
    @IBOutlet weak var songDescriptionLabel: UILabel!
}

extension SearchSongsTableCell {
    func configure(state: Song) {
        self.songDescriptionLabel?.text = state.description
    }
}
