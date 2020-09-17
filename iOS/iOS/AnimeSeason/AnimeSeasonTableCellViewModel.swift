//
//  DiscoverAnimeViewModel.swift
//  iOS
//
//  Created by Steven Berkowitz on R 2/04/07.
//  Copyright © Reiwa 2 nightsquid. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift
import RxDataSources

/**
 fills AnimeSeasonTableViewCell collection view with the anime for a particular year
 */
struct AnimeSeasonViewModel {
    // MARK: - Properties
    let realm = try! Realm()
    let dataSource: RxCollectionViewSectionedReloadDataSource<AnimeSeasonViewSection>
    let animes: Results<RealmAnimeSeries>
    let sections = BehaviorSubject<[AnimeSeasonViewSection]>(value: [])


    // MARK: - Initialization
    init(season: RealmSeason) {

        animes = realm.objects(RealmAnimeSeries.self)
            .sorted(byKeyPath: "name")
            .filter(NSPredicate(format: "season  = %@ AND year = %@", season.season, season.year))

        sections.onNext(
            [AnimeSeasonViewSection(header: "\(season.season) \(season.year)",
                items: Array(animes))]
        )

        // add this as extension of AnimeSeasonViewSection
        dataSource = RxCollectionViewSectionedReloadDataSource<AnimeSeasonViewSection>(configureCell: { _, collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AnimeSeasonCollectionViewCell", for: indexPath) as! AnimeSeasonCollectionViewCell
            cell.isHidden = false
            cell.configureCell(anime: item)
            return cell
        })

    }
}

struct AnimeSeasonViewSection {
    var header: String
    var items: [Item]
}

extension AnimeSeasonViewSection: SectionModelType {
    typealias Item = RealmAnimeSeries

    init(original: AnimeSeasonViewSection, items: [Item]) {
        self = original
        self.items = items
    }
}
