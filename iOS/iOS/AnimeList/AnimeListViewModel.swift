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

    // MARK: - Properties
    let displayedAnimes = BehaviorSubject<[RealmAnimeSeries]>(value: [])
    let savedAnimes: Results<RealmAnimeSeries>
//    var predicates: NSCompoundPredicate
    let firebaseStore = FirebaseStore.sharedInstance

    let disposeBag = DisposeBag()

    // MARK:  - Initialization
    // initialize with saved RealmAnimeSeries
    init() {
        let realm = try! Realm()

        // store all RealmAnime Objects in "savedAnime"
        savedAnimes = realm.objects(RealmAnimeSeries.self).sorted(byKeyPath: "name")

        // testing -> delete all realm objects from database
        // try? realm.write { realm.delete(savedAnimes) }
        // testing

        // make observable from "savedAnime"
        let observableResults = Observable.collection(from: savedAnimes)

        // send observableResults to "displayedAnimes"
        _ = observableResults
            .subscribe(onNext: { results in
                self.displayedAnimes.onNext(results.map { RealmAnimeSeries(value: $0) })
            })
            .disposed(by: disposeBag)

        // get results from firebase *if there are no results saved*
        _ = observableResults
            .filter {
                return $0.count == 0
            }
            .flatMap { _ in
                // MARK: - todo save collection names in database
                Observable.combineLatest(["Summer-2019", "Autumn-2019", "Winter-2020"].map {
                    self.firebaseStore.getAnime(for: $0).asObservable()
                })
            }
            .map { resultArray in
                try? resultArray.forEach { result in
//                    print("result -> \(result)")
                    try realm.write {
                        realm.add(result)
                    }
                }
            }
            .subscribe()
            .disposed(by: disposeBag)
    }

    func filterResults(with searchString: String)  {
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
