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

        // MARK: - todo Combine this with filterAnimeIsObservable
        let totalAnimeCount = allSeasons
            .map {
                let seasonCounts = Array($0).map { $0.count }

                let sum = seasonCounts.reduce(0, { x, y in
                    x + y
                })
                print("sum \(sum)")
                return sum
            }
            .subscribe(onNext: {
                print($0)
            })
            .disposed(by: disposeBag)

        // wait until all animes are loaded
        // MARK: - todo Add season count to RealmSeason, wait till the count is greater than that
        let filteredAnimesObservable = Observable.collection(from: allAnimes)
            .filter { $0.count > 300 }
            .take(1)

        // wait until all the animes have been loaded,
        // Then send each season to a DiscoverAnimeSeasonToSection
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
