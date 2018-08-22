//
//  ViewController.swift
//  AnastasiaMusic
//
//  Created by Yuriy Levytskyy on 8/13/18.
//  Copyright © 2018 Yuriy Levytskyy. All rights reserved.
//

import UIKit
import YoutubeSourceParserKit
import SwiftSoup
import QorumLogs

public func documentsPath() -> String? {
    return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
}

class SearchViewController: UIViewController {
    @IBOutlet weak var queryTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    private var searchResult = Array<(String, String)>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func listAction(_ sender: Any) {
        self.performSegue(withIdentifier: "playSegueue", sender: self)
    }
    
    @IBAction func searchAction(_ sender: Any) {
        searchResult = SearchViewController.search(query: queryTextField.text)
        
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "playSegueue" {
        }
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellId", for: indexPath)
        cell.textLabel?.text = searchResult[indexPath.row].0
        return cell
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CellId") else { return }
        let musicPath = searchResult[indexPath.row].1
        let musicName = searchResult[indexPath.row].0
        SearchViewController.downloadMusicAt(path: musicPath, withName: musicName) { succeeded, localUrl in
            QL2("succeeded: \(succeeded) localUrl: \(localUrl?.absoluteString ?? "")")
            if let _ = localUrl, succeeded {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "playSegueue", sender: self)
                }
            }
        }
        QL2("Downloading \(musicPath)")
        
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}

extension SearchViewController {
    private static func download(url: URL, to localUrl: URL, completion: @escaping (Bool) -> ()) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let request = URLRequest(url: url)
        
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    QL1("Success: \(statusCode)")
                }
                
                do {
                    try FileManager.default.copyItem(at: tempLocalUrl, to: localUrl)
                    completion(true)
                } catch (let writeError) {
                    QL4("Error writing file \(localUrl) : \(writeError)")
                    completion(false)
                }
                
            } else {
                print("Failure: %@", error?.localizedDescription ?? "UNDEFINED ERROR")
                completion(false)
            }
        }
        task.resume()
    }
    
    private static func downloadMusicAt(path: String, withName name: String, completion: @escaping (Bool, URL?) -> ()) {
        let itemUrlString = "http://mp3party.net/\(path)"
        guard let itemUrl = URL(string: itemUrlString) else {
            QL4("Failed to create URL object from \(itemUrlString)")
            completion(false, nil)
            return
        }
        guard let documentsPath = documentsPath() else {
            QL4("NSSearchPathForDirectoriesInDomains failed")
            completion(false, nil)
            return
        }
        let documentsUrl = URL(fileURLWithPath: documentsPath)
        let localUrl = documentsUrl.appendingPathComponent("\(name).mp3")
        do {
            let itemHtml = try String(contentsOf: itemUrl)
            let itemHtmlDocument = try SwiftSoup.parse(itemHtml)
            let itemDiv = try itemHtmlDocument.select("div.download").array().first
            guard let itemElement = try? itemDiv?.select("a").array().first else {
                completion(false, nil)
                return
            }
            guard let itemAttributes = itemElement?.getAttributes()?.asList() else {
                completion(false, nil)
                return
            }
            guard let itemAttribute = itemAttributes.first else {
                completion(false, nil)
                return
            }
            guard let downloadUrl = URL(string: itemAttribute.getValue()) else {
                QL4("Failed to create download URL object from \(itemAttribute.getValue())")
                completion(false, nil)
                return
            }
            SearchViewController.download(url: downloadUrl, to: localUrl) { succeeded in
                QL2("succeeded: \(succeeded) localUrl: \(localUrl)")
                completion(succeeded, localUrl)
            }
        } catch {
            QL4("Error")
            completion(false, nil)
        }
    }
    
    private static func search(query: String?) -> Array<(String, String)> {
        var searchResult = Array<(String, String)>()
        guard let query = query else {
            return searchResult
        }
        let queryString = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        guard let queryUrl = URL(string: "http://mp3party.net/search?q=\(queryString)") else {
            QL4("Failed to create URL object")
            return searchResult
        }
        
        do {
            let searchResultHtml = try String(contentsOf: queryUrl)
            let searchResultHtmlDocument = try SwiftSoup.parse(searchResultHtml)
            let searchResultElements = try searchResultHtmlDocument.select("div.song-item")
            searchResultElements.forEach { searchResultDiv in
                // TODO Use filter
                guard let searchResultElement = try? searchResultDiv.select("a").array().first else {
                    return
                }
                guard let musicPathAttributes = searchResultElement?.getAttributes()?.asList() else {
                    return
                }
                guard let searchResultItemAttribute = musicPathAttributes.first else {
                    return
                }
                guard let searchResultItemName = try? searchResultElement?.html() else {
                    return
                }
                guard let itemName = searchResultItemName else {
                    return
                }
                
                QL1("Name: \(itemName)")
                QL1("Music path: \(searchResultItemAttribute.getValue())")
                searchResult.append((itemName, searchResultItemAttribute.getValue()))
            }
            QL1("searchResult: \(searchResult)")
        } catch Exception.Error(let type, let message) {
            QL4("Error type: \(type) message: \(message)")
        } catch {
            QL4("Error")
        }
        return searchResult
    }
}
