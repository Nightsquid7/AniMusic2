//
//  FilterAnimeViewModel.swift
//  iOS
//
//  Created by Steven Berkowitz on R 2/03/27.
//  Copyright © Reiwa 2 nightsquid. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift

class FilterAnimeViewModel {
    // MARK: - Properties
    let realm = try! Realm()
    let seasons: Observable<Results<RealmSeason>>

    let disposeBag = DisposeBag()

    init() {
        seasons = Observable.collection(from: realm.objects(RealmSeason.self))
    }

}
