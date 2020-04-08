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

struct DiscoverAnimeViewModel {
    // MARK: - Properties
    let realm = try! Realm()
    let dataSource: RxCollectionViewSectionedReloadDataSource<DiscoverAnimeViewSection>
    let sections = BehaviorSubject<[DiscoverAnimeViewSection]>(value: [])
    let seasons: Results<RealmSeason>

    // MARK: - Initialization
    init() {
        let animes = realm.objects(RealmAnimeSeries.self).sorted(byKeyPath: "name")

        // load all RealmSeason objects
        seasons = realm.objects(RealmSeason.self).filter(NSPredicate(format: "selected = %@", NSNumber(value: true))).sorted(byKeyPath: "year", ascending: false)

        sections.onNext( seasons.map { season in

            return DiscoverAnimeViewSection(header: "\(season.season) \(season.year)",
                items: Array(animes.filter(NSPredicate(format: "season  = %@ AND year = %@", season.season, season.year))))
        }
        )

        // add this as extension of DiscoverAnimeViewSection
        dataSource = RxCollectionViewSectionedReloadDataSource<DiscoverAnimeViewSection>(configureCell: { _, collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscoverAnimeCollectionViewCell", for: indexPath) as! DiscoverAnimeCollectionViewCell

            cell.isHidden = false
            cell.configureCell(anime: item)
            return cell
        })

    }
}

struct DiscoverAnimeViewSection {
    var header: String
    var items: [Item]
}

extension DiscoverAnimeViewSection: SectionModelType {
    typealias Item = RealmAnimeSeries

    init(original: DiscoverAnimeViewSection, items: [Item]) {
        self = original
        self.items = items
    }
}
