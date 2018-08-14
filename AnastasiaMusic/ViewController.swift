//
//  ViewController.swift
//  AnastasiaMusic
//
//  Created by Yuriy Levytskyy on 8/13/18.
//  Copyright © 2018 Yuriy Levytskyy. All rights reserved.
//

import UIKit
import YoutubeSourceParserKit

class ViewController: UIViewController {
    @IBOutlet weak var urlTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func downloadAction(_ sender: Any) {
        guard let urlString = urlTextField.text else { return }
        guard let url = NSURL(string: urlString) else { return }
        
        Youtube.h264videosWithYoutubeURL(youtubeURL: url) { videoInfo, error in
            guard let videoURLString = videoInfo?["url"] as? String else { return }
            guard let videoURL = URL(string: videoURLString) else { return }
            guard let videoTitle = videoInfo?["title"] as? String else { return }
            guard let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else { return }
            let documentsUrl = URL(fileURLWithPath: documentsPath)
            let localUrl = documentsUrl.appendingPathComponent("v.avi")
            ViewController.load(url: videoURL, to: localUrl) { succeeded in
                print("\(localUrl)")
                print("\(localUrl.absoluteString)")
            }
        }
    }
}

extension ViewController {
    class func load(url: URL, to localUrl: URL, completion: @escaping (Bool) -> ()) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let request = URLRequest(url: url)
        
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Success: \(statusCode)")
                }
                
                do {
                    try FileManager.default.copyItem(at: tempLocalUrl, to: localUrl)
                    completion(true)
                } catch (let writeError) {
                    print("error writing file \(localUrl) : \(writeError)")
                    completion(false)
                }
                
            } else {
                print("Failure: %@", error?.localizedDescription ?? "UNDEFINED ERROR")
                completion(false)
            }
        }
        task.resume()
    }
}
