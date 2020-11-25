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
        case DefaultSongItem(song: AnimeSong)
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
    let anime: AnimeSeries
    let dataSource: RxTableViewSectionedReloadDataSource<AnimeSongViewSection>!

    let sections = BehaviorSubject<[AnimeSongViewSection]>(value: [])

    init(with anime: AnimeSeries) {
        self.anime = anime

        sections.onNext( anime.songs.map { song in
            // TODO: Add ranges to AnimeSeriesViewModel
            if song.ranges.count > 0 {
                
                return AnimeSongViewSection(header: song.localizedRelation(),
                    items: [.DefaultSongItem(song: song)])
            }

            return AnimeSongViewSection(header: song.localizedRelation(),
                items: [.DefaultSongItem(song: song)])
        })

        dataSource = RxTableViewSectionedReloadDataSource<AnimeSongViewSection>(configureCell: { _, tableView, indexPath, item in
            // configure different cells based on item type
            switch item {
            case .DefaultSongItem(let song):
                let cell: AnimeSongTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.configureCell(from: song)
                return cell
            }
        })

        dataSource.titleForHeaderInSection = { dataSource, index in
            return dataSource.sectionModels[index].header
        }
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
