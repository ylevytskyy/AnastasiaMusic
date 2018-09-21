//
//  Song.swift
//  AnastasiaMusic
//
//  Created by Yuriy Levytskyy on 9/20/18.
//  Copyright © 2018 Yuriy Levytskyy. All rights reserved.
//

import Foundation

public struct Song {
    public let description: String
    public let artist: String?
    public let title: String?
    public let query: String
    public let detailsURL: URL
    public let remoteURL: URL?
    public let localURL: URL?
    public let bytesDownloaded: Int
    public let isDownloaded: Bool
    
    public init(
        description: String,
        artist: String?,
        title: String?,
        query: String,
        detailsURL: URL,
        remoteURL: URL?,
        localURL: URL?,
        bytesDownloaded: Int,
        isDownloaded: Bool) {
        self.description = description
        self.artist = artist
        self.title = title
        self.query = query
        self.detailsURL = detailsURL
        self.remoteURL = remoteURL
        self.localURL = localURL
        self.bytesDownloaded = bytesDownloaded
        self.isDownloaded = isDownloaded
    }
}

extension Song: Equatable {}
