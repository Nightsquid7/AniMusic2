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

    let sections = BehaviorSubject<[AnimeSeriesViewSection]>(value: [])

    init(with anime: RealmAnimeSeries) {
        self.anime = anime

        var openingCount: Int = 1, endingCount: Int = 1
        var headerString: String = ""

        // create sections
        sections.onNext( anime.songs.map { song in
            guard let relation = song.relation else {
               // else add song as default
               return AnimeSeriesViewSection(header: song.relation ?? "no relation...", items: [.DefaultSongItem(song: song)])}
            // create string for header
            switch relation {
            case "opening":
                headerString = "\(relation) \(openingCount)"
                openingCount += 1
            case "ending":
                headerString = "\(relation) \(endingCount)"
                endingCount += 1

            default:
                headerString = relation
            }
            if let _ = song.ranges.first?.start.value, let _ = song.ranges.first?.end.value {
                for _ in song.sources {
                    // add item as spotify or apple music song item
                    return AnimeSeriesViewSection(header: "\(headerString)",
                        items: [.DefaultSongItem(song: song)])
                }
            }
            return AnimeSeriesViewSection(header: headerString,
                items: [.DefaultSongItem(song: song)])
        })
    }
}
