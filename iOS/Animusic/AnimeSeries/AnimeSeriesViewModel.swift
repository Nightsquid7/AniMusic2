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

        sections.onNext( anime.songs.map { song in
            // TODO: Add ranges to AnimeSeriesViewModel
            if song.ranges.count > 0 {
                let earliest = song.ranges.map {$0.start}.min() ?? 0
                let latest = song.ranges.map { $0.end }.max() ?? 0

                return AnimeSongViewSection(header: "\(song.relation) ep \(earliest) - ep \(latest)",
                    items: [.DefaultSongItem(song: song)])
            }

            return AnimeSongViewSection(header: song.relation,
                items: [.DefaultSongItem(song: song)])
        })
    }

    @objc func setBookmarked() {
        do {
            try realm.write {
                anime.bookmarked = !anime.bookmarked
            }
        } catch {
            print(error)
        }
    }
}
