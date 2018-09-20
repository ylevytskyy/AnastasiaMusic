//
//  Song.swift
//  AnastasiaMusic
//
//  Created by Yuriy Levytskyy on 9/20/18.
//  Copyright © 2018 Yuriy Levytskyy. All rights reserved.
//

import Foundation

public struct Song {
    public let artist: String?
    public let title: String?
    public let query: String
    public let description: String
    public let detailsURL: URL
    public let remoteURL: URL?
    public let localURL: URL?
    public let bytesDownloaded: Int
    public let isDownloaded: Bool
    
    public init(
        artist: String?,
        title: String?,
        query: String,
        description: String,
        detailsURL: URL,
        remoteURL: URL?,
        localURL: URL?,
        bytesDownloaded: Int,
        isDownloaded: Bool) {
        self.artist = artist
        self.title = title
        self.query = query
        self.description = description
        self.detailsURL = detailsURL
        self.remoteURL = remoteURL
        self.localURL = localURL
        self.bytesDownloaded = bytesDownloaded
        self.isDownloaded = isDownloaded
    }
}

extension Song: Equatable {}
