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
//import RxRealm

class FilterAnimeViewModel {
    // MARK: - Properties
    let seasons: Observable<Results<RealmSeason>>
//    let years = Observable<[String]>()

    init() {
        seasons = Observable.collection(from: try! Realm().objects(RealmSeason.self))
//        years = seasons.flatMap { season in
//            season.year
////            print(season)
//        }
        print("in FilterAnimeViewModel -> ")
        print("seasons -> \(seasons)")
//        print("years -> \(years)")
    }

}
