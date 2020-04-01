//
//  AnimeListViewModel.swift
//  iOS
//
//  Created by Steven Berkowitz on R 2/03/23.
//  Copyright © Reiwa 2 nightsquid. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift
import RxRealm
import RxDataSources

struct AnimeListViewSection {
    var header: String
    var items: [RealmAnimeSeries]
}

extension AnimeListViewSection: SectionModelType {
    init(original: AnimeListViewSection, items: [RealmAnimeSeries]) {
        self = original
        self.items = items
    }

}

class AnimeListViewModel {
    // MARK: - Properties
    let savedAnimes: Results<RealmAnimeSeries>

    var sections = BehaviorSubject<[AnimeListViewSection]>(value: [])
    let seasons: Results<RealmSeason>

    let firebaseStore = FirebaseStore.sharedInstance
    let disposeBag = DisposeBag()

    // MARK: - Initialization
    // initialize with saved RealmAnimeSeries
    init() {
        let realm = try! Realm()

        // load all RealmAnime Objects
        savedAnimes = realm.objects(RealmAnimeSeries.self).sorted(byKeyPath: "name")

        // MARK: - todo convert sections to Observable
        //  -> Sections is currently not reflecting changes to changes to RealmSeason selected
        // load all RealmSeason objects
        seasons = realm.objects(RealmSeason.self).filter(NSPredicate(format: "selected = %@", NSNumber(value: true))).sorted(byKeyPath: "year", ascending: false)

        // add animes to sections -> sections filtered by season/dear
        sections.onNext( seasons.map { season in
            return AnimeListViewSection(header: "\(season.season) \(season.year)", items: Array(savedAnimes.filter(NSPredicate(format: "season  = %@ AND year = %@", season.season, season.year))))
        })
    }

    func filterResults(with searchString: String) {
        if !searchString.isEmpty {
            sections.onNext(
                [AnimeListViewSection(header: "", items: Array(savedAnimes.filter(NSPredicate(format: "name CONTAINS %@", searchString))))]
            )
        } else {
            sections.onNext( seasons.map { season in
                return AnimeListViewSection(header: "\(season.season) \(season.year)", items: Array(savedAnimes.filter(NSPredicate(format: "season  = %@ AND year = %@", season.season, season.year))))
            })
        }

    }

    func filterResults(with predicate: NSCompoundPredicate) {

    }
}
