//
//  AnimeSeriesViewModel.swift
//  
//
//  Created by Steven Berkowitz on R 2/03/24.
//

import Foundation
import RxSwift
import RealmSwift

class AnimeSeriesViewModel {

    let realm = try! Realm()
    let anime: RealmAnimeSeries
    let displayedSongs = BehaviorSubject<[RealmAnimeSong]>(value: [])

    init(with anime: RealmAnimeSeries) {
        self.anime = anime 
        displayedSongs.onNext(anime.songs.map { $0 }.sorted(by: { $0 < $1 }))
    }
}
