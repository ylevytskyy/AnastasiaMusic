//
//  PlayerViewController.swift
//  AnastasiaMusic
//
//  Created by Yuriy Levytskyy on 8/22/18.
//  Copyright © 2018 Yuriy Levytskyy. All rights reserved.
//

import UIKit
import QorumLogs

class PlayerViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var musicFiles: [URL]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            QL4("FileManager.default.urls failed")
            return
        }
        guard let fileURLs = try? FileManager.default.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil) else {
            QL4("FileManager.default.contentsOfDirectory failed")
            return
        }
        
        musicFiles = fileURLs
        tableView.reloadData()
    }
}

extension PlayerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let musicFiles = musicFiles else { return 0 }
        return musicFiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PlayerTableCell.reuseId, for: indexPath) as! PlayerTableCell
        cell.musicUrl = musicFiles![indexPath.row]
        return cell
    }
}
