//
//  DiscoverAnimeViewModel.swift
//  iOS
//
//  Created by Steven Berkowitz on 2020/05/24.
//  Copyright © 2020 nightsquid. All rights reserved.
//

import RealmSwift
import RxSwift
import RxDataSources

class DiscoverAnimeViewModel {

    // MARK: - Properties
    let allAnimes: Results<RealmAnimeSeries>
    var dataSource: RxTableViewSectionedReloadDataSource<DiscoverAnimeSeasonViewSection>?
    var sections = BehaviorSubject<[DiscoverAnimeSeasonViewSection]>(value: [])

    let realm = try! Realm()
    let disposeBag = DisposeBag()

    init() {
        allAnimes = realm.objects(RealmAnimeSeries.self)

        let allSeasons = Observable.collection(from: realm.objects(RealmSeason.self))

        // wait until all animes are loaded
        // MARK: - todo Add season count to RealmSeason, wait till the count is greater than that
        let filteredAnimesObservable = Observable.collection(from: allAnimes)
//            .filter { $0.count > 300 }
            .take(1)

        // wait until all the animes have been loaded,
        _ = Observable.combineLatest(filteredAnimesObservable, allSeasons)
            .map { _, seasons in
                // Then send each season to a DiscoverAnimeSeasonToSection
                // -> display in DiscoverAnimeViewController AnimeSeasontableView
                self.sections.onNext( seasons
                                        .sorted(byKeyPath: "season", ascending: false)
                                        .sorted(byKeyPath: "year", ascending: false)
                                        .map { season in
                                            DiscoverAnimeSeasonViewSection(items: [season])
                })
            }
            .subscribe()
            .disposed(by: disposeBag)

    }
}

struct DiscoverAnimeSeasonViewSection {
    var items: [RealmSeason]
}

extension DiscoverAnimeSeasonViewSection: SectionModelType {
    init(original: DiscoverAnimeSeasonViewSection, items: [RealmSeason]) {
        self = original
        self.items = items
    }

}
