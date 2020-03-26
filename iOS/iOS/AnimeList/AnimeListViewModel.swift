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
    var savedAnime: Results<RealmAnimeSeries>

    let firebaseStore = FirebaseStore.sharedInstance

    let disposeBag = DisposeBag()

    // initialize with saved RealmAnimeSeries
    init() {
        let realm = try! Realm()

        // ()r()1rrtry? realm.write { realm.deleteAll() }
        // store all RealmAnime Objects in savedAnime
        savedAnime = realm.objects(RealmAnimeSeries.self).sorted(byKeyPath: "name")


        let observableResults = Observable.collection(from: savedAnime)

        // load results to displayedAnimes
        _ = observableResults
            .subscribe(onNext: { results in
                self.displayedAnimes.onNext(results.map { RealmAnimeSeries(value: $0) })
            })
            .disposed(by: disposeBag)

        // get results from firebase if there are no results
        _ = observableResults
            .filter {
                return $0.count == 0
            }
            .flatMap { _ in
                self.firebaseStore.getAnime()
            }
            .map { result in
                try realm.write {
                    realm.add(result)
                }
            }
            .subscribe()
            .disposed(by: disposeBag)
    }

    func filterResults(with searchString: String)  {
        let filteredResults: Results<RealmAnimeSeries>
        if searchString.isEmpty {
            // display unfiltered results
            filteredResults = savedAnime
        } else {
            filteredResults = savedAnime.filter(NSPredicate(format: "name CONTAINS %@", searchString))
        }
        displayedAnimes.onNext(filteredResults.map { RealmAnimeSeries(value: $0) })
    }

}
