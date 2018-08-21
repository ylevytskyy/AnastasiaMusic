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

class SearchViewController: UIViewController {
    @IBOutlet weak var queryTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    private var searchResult = Array<(String, String)>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func parseSearchResult(query: String?) -> Array<(String, String)> {
        var searchResult = Array<(String, String)>()
        guard let query = query else {
            return searchResult
        }
        let queryString = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        guard let url = URL(string: "http://mp3party.net/search?q=\(queryString)") else {
            QL4("Failed to create URL object")
            return searchResult
        }
        
        do {
            let searchResultHtml = try String(contentsOf: url)
            let searchResultHtmlDocument = try SwiftSoup.parse(searchResultHtml)
            let searchResultElements = try searchResultHtmlDocument.select("div.song-item")
            searchResultElements.forEach { searchResultElement in
                // TODO Use filter
                guard let searchResultDiv = try! searchResultElement.select("a").array().first else {
                    return
                }
                guard let musicPathAttributes = searchResultDiv.getAttributes()?.asList() else {
                    return
                }
                guard let searchResultItemAttribute = musicPathAttributes.first else {
                    return
                }
                guard let searchResultItemName = try? searchResultDiv.html() else {
                    return
                }
                QL1("Name: \(searchResultItemName)")
                QL1("music path: \(searchResultItemAttribute.getValue())")
                searchResult.append((searchResultItemName, searchResultItemAttribute.getValue()))
            }
            QL1("\(searchResult)")
        } catch Exception.Error(let type, let message) {
            QL4("type: \(type) message: \(message)")
        } catch {
            QL4("Error")
        }
        return searchResult
    }
    
    @IBAction func searchAction(_ sender: Any) {
        searchResult = parseSearchResult(query: queryTextField.text)
        
        tableView.reloadData()
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

extension SearchViewController {
    class func load(url: URL, to localUrl: URL, completion: @escaping (Bool) -> ()) {
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
                    QL4("error writing file \(localUrl) : \(writeError)")
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
