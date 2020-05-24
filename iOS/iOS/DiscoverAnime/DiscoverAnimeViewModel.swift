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

        // wait until all animes are loaded
        // MARK: - todo Add season count to RealmSeason, wait till the count is greater than that
        let filteredAnimesObservable = Observable.collection(from: allAnimes)
            .map { return $0 }
            .filter { $0.count > 190 }
            .take(1)

        let allSeasons = Observable.collection(from: realm.objects(RealmSeason.self))

        // create AnimeSeasonViewManager/collection view
        // for each season.
        _ = Observable.combineLatest(filteredAnimesObservable, allSeasons)
            .map { _, seasons in
                self.sections.onNext( seasons.map { season in
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
