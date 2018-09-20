//
//  SongUseCase.swift
//  Platform
//
//  Created by Yuriy Levytskyy on 9/20/18.
//  Copyright © 2018 Yuriy Levytskyy. All rights reserved.
//

import RxSwift
import QorumLogs
import SwiftSoup
import AVFoundation
import Domain

private func download(url: URL, to localUrl: URL) -> Observable<Void> {
    return Observable<Void>.create { observable in
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let request = URLRequest(url: url)
        
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let error = error {
                QL4("\(error.localizedDescription)")
                observable.onError(error)
                return
            }
            guard let tempLocalUrl = tempLocalUrl else {
                observable.onError(NSError(domain: "Network", code: 1, userInfo: nil))
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode == 200 else {
                observable.onError(NSError(domain: "Network", code: 1, userInfo: nil))
                return
            }
            
            do {
                try FileManager.default.copyItem(at: tempLocalUrl, to: localUrl)
                observable.onNext(())
                observable.onCompleted()
            } catch (let error) {
                QL4("Error writing file \(localUrl) : \(error.localizedDescription)")
                observable.onError(error)
            }
        }
        task.resume()
        return Disposables.create { }
    }
}

final class SongUseCase : Domain.SongUseCase {
    var songs: Observable<[Song]> {
        return repository.entities
    }
    
    private let scheduler = ConcurrentDispatchQueueScheduler(qos: .utility)
    private let repository: Repository<Domain.Song>
    
    private var audioPlayer: AVAudioPlayer?
    
    init(repository: Repository<Domain.Song>) {
        self.repository = repository
    }
    
    func search(query: String) -> Observable<[Song]> {
        return Single<String>.create { single in
            do {
                let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                if let queryUrl = URL(string: "http://mp3party.net/search?q=\(encodedQuery)") {
                    // Download result HTML
                    let html = try String(contentsOf: queryUrl)
                    single(.success(html))
                } else {
                    single(.error(NSError(domain: "Network", code: 1, userInfo: nil)))
                }
            }
            catch let error {
                single(.error(error))
            }
            return Disposables.create { }
        }
        .map { Song.make(query: query, searchResultHtml: $0) }
        .asObservable()
        .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
        .observeOn(MainScheduler.instance)
    }
    
    func query(description: String) -> Observable<[Song]> {
        return repository.query(description: description)
    }
    
    func download(song: Song) -> Observable<Void> {
        return Single<Void>.create { single in
            do {
                let documentDirectoryURL = URL(fileURLWithPath: FileManager.default.documentDirectory())
                let localURL = documentDirectoryURL.appendingPathComponent("\(song.description).mp3")
                
                let detailsHtml = try String(contentsOf: song.detailsURL)
                let detailsDocument = try SwiftSoup.parse(detailsHtml)
                let downloadDiv = try detailsDocument.select("div.download").array().first
                if let downloadAttribute = try downloadDiv?.select("a").array().first?.getAttributes()?.asList().first {
                    if let downloadUrl = URL(string: downloadAttribute.getValue()) {
                        _ = Platform
                            .download(url: downloadUrl, to: localURL)
                            .subscribe(onNext: { _ in
                                _ = self.repository
                                    .insert(entity: song.with(remoteURL: downloadUrl, localURL: localURL))
                                    .subscribe(
                                        onNext: { _ in single(.success(())) },
                                        onError: { error in single(.error(error))})
                            }, onError: { error in
                                single(.error(error))
                            })
                    } else {
                        single(.error(NSError(domain: "Network", code: 3, userInfo: nil)))
                    }
                } else {
                    single(.error(NSError(domain: "Network", code: 2, userInfo: nil)))
                }
            } catch let error {
                single(.error(error))
            }
            return Disposables.create {}
        }.asObservable().observeOn(MainScheduler.instance)
    }
    
    func play(song: Song) -> Observable<Void> {
        return Single<Void>.create { observer in
            if let localURL = song.localURL {
                do {
                    self.audioPlayer = try AVAudioPlayer(contentsOf: localURL)
                    self.audioPlayer!.prepareToPlay()
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                    self.audioPlayer!.play()
                    observer(.success(()))
                } catch let error {
                    observer(.error(error))
                }
            } else {
                observer(.error(NSError(domain: "", code: 1, userInfo: nil)))
            }
            return Disposables.create {}
        }.asObservable()
    }
    
    func stop() -> Observable<Void> {
        audioPlayer?.stop()
        return Observable<Void>.just(())
    }
}
