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
    var items: [SectionItem]

    enum SectionItem {
        case DefaultSongItem(song: RealmAnimeSong)
        case SpotifySongItem(song: RealmAnimeSong, source: RealmSongSearchResult)
        case AppleMusicSongItem(song: RealmAnimeSong)
    }
}

extension AnimeSeriesViewSection: SectionModelType {
    typealias Item = SectionItem

    init(original: Self, items: [Item]) {
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
        displayedSongs.onNext(anime.songs.map { $0 })// .sorted(by: { $0 < $1 }))

        // create sections
        sections.onNext( anime.songs.map { song in
            if let start = song.ranges.first?.start.value, let end = song.ranges.first?.end.value, let relation = song.relation {
                for source in song.sources {
                    // add item as spotify or apple music song item
                    if source.source == "Spotify" {
                        return AnimeSeriesViewSection(header: "\(relation) start: \(start)  end: \(end)",
                                                      items: [.SpotifySongItem(song: song, source: source)])
                    } else {
                        return AnimeSeriesViewSection(header: "\(relation) start: \(start)  end: \(end)", items: [.AppleMusicSongItem(song: song)])
                    }
                }
            }
            // else add song as default
            return AnimeSeriesViewSection(header: song.relation ?? "no relation...", items: [.DefaultSongItem(song: song)])
        })
    }
}
