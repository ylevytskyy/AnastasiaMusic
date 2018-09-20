//
//  Song.swift
//  Platform
//
//  Created by Yuriy Levytskyy on 9/20/18.
//  Copyright © 2018 Yuriy Levytskyy. All rights reserved.
//

import SwiftSoup
import RxSwift
import Domain
import FMDB

extension Song {
    static func make(query: String, searchResultHtml: String) -> [Song] {
        guard let searchResultHtmlDocument = try? SwiftSoup.parse(searchResultHtml) else {
            return [Song]()
        }
        guard let searchResultElements = try? searchResultHtmlDocument.select("div.song-item") else {
            return [Song]()
        }
        let html: [Element] = searchResultElements
            .compactMap { try? $0.select("a").array().first }
            .compactMap { $0 }
        let elements: [String] = html
            .compactMap { try! $0.text() }
        let attributes: [String] = html
            .compactMap { $0.getAttributes()?.asList() }
            .compactMap { $0?.first }
            .compactMap { $0.getValue() }
        return zip(elements, attributes)
            .map {
                return Domain.Song(
                    artist: nil,
                    title: nil,
                    query: query,
                    description: $0,
                    detailsURL: URL(string: "http://mp3party.net/\($1)")!,
                    remoteURL: nil,
                    localURL: nil,
                    bytesDownloaded:0,
                    isDownloaded: false)
        }
    }
    
    func with(remoteURL: URL, localURL: URL) -> Song {
        return Song(
            artist: artist,
            title: title,
            query: query,
            description: description,
            detailsURL: detailsURL,
            remoteURL: remoteURL,
            localURL: localURL,
            bytesDownloaded: bytesDownloaded,
            isDownloaded: isDownloaded)
    }
}

extension Song: StorableType {
    static let sqlTableName = "Song"
    
    static let sqlColumnNames = ["artist", "title", "query", "description", "detailsURL", "remoteURL", "localURL", "bytesDownloaded", "isDownloaded"]
    static let sqlColumnDescriptions = ["TEXT NULL", "TEXT NULL", "TEXT", "TEXT NULL", "TEXT", "TEXT", "TEXT", "INT", "INT"]
    
    init(resultSet: FMResultSet) {
        self.artist = resultSet.string(forColumn: "artist")
        self.title = resultSet.string(forColumn: "title")
        self.query = resultSet.string(forColumn: "query")!
        self.description = resultSet.string(forColumn: "description")!
        self.detailsURL = URL(string: resultSet.string(forColumn: "detailsURL")!)!
        self.remoteURL = URL(optionalString: resultSet.string(forColumn: "remoteURL"))
        self.localURL = URL(optionalString: resultSet.string(forColumn: "localURL"))
        self.bytesDownloaded = Int(resultSet.int(forColumn: "bytesDownloaded"))
        self.isDownloaded = resultSet.int(forColumn: "isDownloaded") != 0
    }

    func sqlValue(column: String) -> Any? {
        switch column {
            case "artist":
                return artist
            case "title":
                return title
            case "query":
                return query
            case "description":
                return description
            case "detailsURL":
                return detailsURL
            case "remoteURL":
                return remoteURL
            case "localURL":
                return localURL
            case "bytesDownloaded":
                return bytesDownloaded
            case "isDownloaded":
                return isDownloaded
        default:
            return nil
        }
    }
}
