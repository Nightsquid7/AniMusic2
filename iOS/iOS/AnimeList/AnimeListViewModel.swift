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
    let displayedAnimes = BehaviorSubject<[RealmAnimeSeries]>(value: [])
    let savedAnimes: Results<RealmAnimeSeries>
    let firebaseStore = FirebaseStore.sharedInstance
    var sections = [AnimeListViewSection]()
    let seasons: Results<RealmSeason>
    let disposeBag = DisposeBag()

    // MARK: - Initialization
    // initialize with saved RealmAnimeSeries
    init() {
        let realm = try! Realm()

        // load all RealmAnime Objects
        savedAnimes = realm.objects(RealmAnimeSeries.self).sorted(byKeyPath: "name")

        // load all RealmSeason objects
        seasons = realm.objects(RealmSeason.self).sorted(byKeyPath: "year", ascending: false)

        sections = seasons.map { season in
            return AnimeListViewSection(header: "\(season.season) \(season.year)", items: Array(savedAnimes.filter(NSPredicate(format: "season  = %@ AND year = %@", season.season, season.year))))
        }

    }

    func filterResults(with searchString: String) {
        var filteredAnimes = savedAnimes
        if !searchString.isEmpty {
            filteredAnimes = savedAnimes.filter(NSPredicate(format: "name CONTAINS %@", searchString))
        }
        displayedAnimes.onNext(filteredAnimes.map { RealmAnimeSeries(value: $0) })
    }

    func filterResults(with predicate: NSCompoundPredicate) {
        let filteredAnime = savedAnimes
        displayedAnimes.onNext(filteredAnime.filter(predicate).map { RealmAnimeSeries(value: $0) })
    }
}
