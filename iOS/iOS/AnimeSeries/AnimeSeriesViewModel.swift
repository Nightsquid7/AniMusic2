//
//  AnimeSeriesViewModel.swift
//  
//
//  Created by Steven Berkowitz on R 2/03/24.
//

import Foundation
import RxSwift
import RealmSwift
import RxDataSources

struct AnimeSeriesViewSection {
    var header: String
    var items: [RealmAnimeSong]
}

extension AnimeSeriesViewSection: SectionModelType {
    init(original: Self, items: [RealmAnimeSong]) {
        self = original
        self.items = items
    }
}

class AnimeSeriesViewModel {

    let realm = try! Realm()
    let anime: RealmAnimeSeries
    let displayedSongs = BehaviorSubject<[RealmAnimeSong]>(value: [])

    let sections = BehaviorSubject<[AnimeSeriesViewSection]>(value: [])

    init(with anime: RealmAnimeSeries) {
        self.anime = anime
        displayedSongs.onNext(anime.songs.map { $0 }.sorted(by: { $0 < $1 }))

        sections.onNext( anime.songs.map { song in
            if let start = song.ranges.first?.start.value, let end = song.ranges.first?.end.value, let relation = song.relation {
                return AnimeSeriesViewSection(header: "\(relation) start: \(start) end: \(end)", items: [song])
            }
            return AnimeSeriesViewSection(header: song.relation ?? "no relation...", items: [song])
        })
    }
}
