//
//  SongListTableCell.swift
//  AnastasiaMusic
//
//  Created by Yuriy Levytskyy on 8/22/18.
//  Copyright © 2018 Yuriy Levytskyy. All rights reserved.
//

import UIKit
import Domain
import QorumLogs

class SongListTableCell: UITableViewCell {
    public static let reuseId = "CellId"
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var musicTitleLabel: UILabel!

    private var song: Domain.Song!
    private var useCase: Domain.SongUseCase!
    
    @IBAction func playAction(_ sender: Any) {
        _ = useCase.play(song: song).subscribe()
    }
    
    @IBAction func stopAction(_ sender: Any) {
        _ = useCase.stop().subscribe()
        
        playButton.setTitle("Play", for: .normal)
        playButton.isEnabled = true
    }
    
    func configure(song: Domain.Song, useCase: Domain.SongUseCase) {
        self.song = song
        self.useCase = useCase
        self.musicTitleLabel.text = song.description
    }
}
