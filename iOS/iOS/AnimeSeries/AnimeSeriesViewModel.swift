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

struct AnimeSongViewSection {
    var header: String
    var items: [SectionItem]

    enum SectionItem {
        case DefaultSongItem(song: RealmAnimeSong)
    }
}

extension AnimeSongViewSection: SectionModelType {
    typealias Item = SectionItem

    init(original: Self, items: [Item]) {
        self = original
        self.items = items
    }
}

class AnimeSeriesViewModel {

    let realm = try! Realm()
    let anime: RealmAnimeSeries

    let sections = BehaviorSubject<[AnimeSongViewSection]>(value: [])

    init(with anime: RealmAnimeSeries) {
        self.anime = anime

        // create sections
        sections.onNext( anime.songs.map { song in
            guard let relation = song.relation else {
               // else add song as default
               return AnimeSongViewSection(header: "Mystery Song", items: [.DefaultSongItem(song: song)])
            }

            if let startRange = song.ranges.first?.start.value, let endRange =  song.ranges.first?.end.value {
                for _ in song.sources {
                    // add item as spotify or apple music song item
                   
                    return AnimeSongViewSection(header: "\(relation) ep \(startRange) - ep \(endRange)",
                        items: [.DefaultSongItem(song: song)])
                }
            }
            return AnimeSongViewSection(header: relation,
                items: [.DefaultSongItem(song: song)])
        })
    }
}
