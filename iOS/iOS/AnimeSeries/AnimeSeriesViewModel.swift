//
//  AnimeSeriesViewModel.swift
//  
//
//  Created by Steven Berkowitz on R 2/03/24.
//

import Foundation
import RxSwift

class AnimeSeriesViewModel {

    let anime: RealmAnimeSeries
    let displayedSongs = BehaviorSubject<[RealmAnimeSong]>(value: [])

    init(with anime: RealmAnimeSeries) {
        self.anime = anime
        displayedSongs.onNext(anime.songs.map { $0 }.sorted(by: { song1, song2 in
//            return song1.ranges.first!.start > song2.ranges.first!.start
            return true
        }))
    }
}
