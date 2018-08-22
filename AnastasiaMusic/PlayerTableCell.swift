//
//  PlayerTableCell.swift
//  AnastasiaMusic
//
//  Created by Yuriy Levytskyy on 8/22/18.
//  Copyright © 2018 Yuriy Levytskyy. All rights reserved.
//

import UIKit
import AVFoundation
import QorumLogs

class PlayerTableCell: UITableViewCell {
    public static let reuseId = "CellId"
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var musicTitleLabel: UILabel!

    public var musicUrl: URL? {
        didSet {
            musicTitleLabel.text = musicTitle
        }
    }
    public var musicTitle: String? {
        guard let musicUrlParts = musicUrl?.absoluteString.components(separatedBy: "/") else { return nil }
        guard musicUrlParts.count > 1 else { return nil}
        return musicUrlParts.last?.removingPercentEncoding
    }
    
    private var audioPlayer: AVAudioPlayer?
    
    @IBAction func playAction(_ sender: Any) {
        QL1("playAction")
        
        guard let musicUrl = musicUrl else {
            QL3("NULL music URL")
            return
        }
        
        guard let audioPlayer = try? AVAudioPlayer(contentsOf: musicUrl) else {
            QL4("Failed to create audio player")
            return
        }
        
        self.audioPlayer = audioPlayer
        audioPlayer.prepareToPlay()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            audioPlayer.play()
            
            playButton.setTitle("Playing", for: .normal)
            playButton.isEnabled = false
        } catch let error {
            QL4("\(error)")
        }
    }
    
    @IBAction func stopAction(_ sender: Any) {
        QL1("stopAction")
        
        audioPlayer?.stop()
        
        playButton.setTitle("Play", for: .normal)
        playButton.isEnabled = true
    }
}
