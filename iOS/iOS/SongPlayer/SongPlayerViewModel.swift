//
//  SongPlayerViewController.swift
//  iOS
//
//  Created by Steven Berkowitz on R 2/04/03.
//  Copyright © Reiwa 2 nightsquid. All rights reserved.
//
import Foundation

class SongPlayerViewModel {

    let song: RealmAnimeSong
    let source: RealmSongSearchResult

    init(song: RealmAnimeSong, source: RealmSongSearchResult) {
        self.song = song
        self.source = source
    }

}
