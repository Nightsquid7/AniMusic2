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

class DisplayAnimeViewModel {

    // MARK: - Properties
    var dataSource: RxTableViewSectionedReloadDataSource<DisplayAnimeSeasonViewSection>?
    var sections = BehaviorSubject<[DisplayAnimeSeasonViewSection]>(value: [])

    let realm = try! Realm()
    let disposeBag = DisposeBag()
    let store = FirebaseStore.sharedInstance

    init() {

        let allSeasons = Observable.collection(from: realm.objects(RealmSeason.self))

        // wait until all animes are loaded
        let filteredAnimesObservable = Observable.collection(from: realm.objects(RealmAnimeSeries.self))
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
                        DisplayAnimeSeasonViewSection(items: [season])
                })
            }
            .subscribe()
            .disposed(by: disposeBag)

    }
}

struct DisplayAnimeSeasonViewSection {
    var items: [RealmSeason]
}

extension DisplayAnimeSeasonViewSection: SectionModelType {
    init(original: DisplayAnimeSeasonViewSection, items: [RealmSeason]) {
        self = original
        self.items = items
    }

}
