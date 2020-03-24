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

class AnimeListViewModel {

    let displayedAnimes = BehaviorSubject<[RealmAnimeSeries]>(value: [])
    let results: Results<RealmAnimeSeries>

    let disposeBag = DisposeBag()

    // initialize with saved RealmAnimeSeries
    init() {
        let realm = try! Realm()
        results = realm.objects(RealmAnimeSeries.self).sorted(byKeyPath: "name")
        displayedAnimes.onNext(results.map { RealmAnimeSeries(value: $0) })
        // if results.count  <= 0 // call firebase
    }

    func filterResults(with searchString: String)  {
        let filteredResults: Results<RealmAnimeSeries>
        if searchString.isEmpty {
            // display unfiltered results
            filteredResults = results
        } else {
            filteredResults = results.filter(NSPredicate(format: "name CONTAINS %@", searchString))
        }
        displayedAnimes.onNext(filteredResults.map { RealmAnimeSeries(value: $0) })
    }

}
