//
//  FirebaseStore.swift
//  iOS
//
//  Created by Steven Berkowitz on R 2/03/22.
//  Copyright © Reiwa 2 nightsquid. All rights reserved.
//

import Foundation
import FirebaseFirestore
import RxSwift
import RealmSwift
import RxRealm
import os.log

class FirebaseStore {
    // MARK: - Properties
    let realm: Realm!
    static let sharedInstance = FirebaseStore()
    let db = Firestore.firestore()
    let disposeBag = DisposeBag()
    // used to flag when downloading anime is finished
    var numberOfAnimeInFirebase: Int = .max
    var numberOfSeasonsInFirebase = BehaviorSubject<Int>(value: 0)
    var numberOfSeasonsDownloaded = BehaviorSubject<Int>(value: 0)
    
    enum FirebaseError: Error {
        case couldNotGetAnime(season: Season, error: Error)
        case couldNotGetSeason(_ error: Error)
    }

    init() {
        var config = Realm.Configuration()
        config.deleteRealmIfMigrationNeeded = true
        realm = try? Realm(configuration: config)
    }

    var firebaseSeasons: Observable<[Season]>!
    var downloadedSeasons: Observable<[AnimeSeries]>!
    
    public func updateLocalRealm() {
        let savedSeasons = Observable.collection(from: realm.objects(Season.self))
            .take(1)

        firebaseSeasons = getSeasonsListFromFireStore()
            .asObservable()
            .share()

        // sum all counts of anime from firebase
        firebaseSeasons
            .subscribe(onNext: { seasons in
                self.numberOfSeasonsInFirebase.onNext(seasons.count)
                
                self.numberOfAnimeInFirebase = seasons
                    .map { $0.animeCount() }
                    .reduce(0, +)
            })
            .disposed(by: disposeBag)
        
        let seasonsToDownload = Observable.combineLatest(savedSeasons, firebaseSeasons)
            .map { savedSeasons, firebaseSeasons  -> [Season] in

                let savedSeasonNames = savedSeasons.map { $0.titleString() }
                return firebaseSeasons.compactMap { seasonInFirebase in
                    if savedSeasonNames.contains(seasonInFirebase.titleString()) {
                        return nil
                    }
                    print("downloading new season \(seasonInFirebase.titleString())")
                    return seasonInFirebase
                }
            }
            .flatMap { seasons  in
                Observable.from(seasons)
            }
            .share()

        // save seasons list to realm
        _ = seasonsToDownload
            .subscribe(realm.rx.add())
            .disposed(by: disposeBag)

        downloadedSeasons = seasonsToDownload
            .flatMap { season in
               self.getAnime(from: season)
            }
            .share()

        // save animes to Realm
        downloadedSeasons
            .subscribe(realm.rx.add())
            .disposed(by: disposeBag)
        
        downloadedSeasons
            .subscribe(onNext: { season in
                self.numberOfSeasonsDownloaded.onNext(try! self.numberOfSeasonsDownloaded.value() + 1)
            })
            .disposed(by: disposeBag)
    }

    // Delete everything in realm
    public func removeDefaultRealm() {
        do {
            print("deleting default Realm configuration")
            try FileManager.default.removeItem(at: Realm.Configuration.defaultConfiguration.fileURL!)
        } catch {
            print(error)
        }
    }

    // get the list of seasons of animes stored in firebase
    private func getSeasonsListFromFireStore() -> Single<[Season]> {
        return Single<[Season]>.create { single in
            let seasonRef = self.db.collection("Seasons-List")
            seasonRef.getDocuments { (querySnapshot, error) in
                if let error = error {
                    single(.error(FirebaseError.couldNotGetSeason(error)))
                    return
                }
                guard let documents = querySnapshot?.documents else { return }
                var seasons = [Season]()
                for document in documents {
                    var data = document.data()
                    let timestamp = data.removeValue(forKey: "Time")
                                        let seasonData = try? JSONSerialization.data(withJSONObject: data, options: [])
                    if let season = try? JSONDecoder().decode(Season.self, from: seasonData!) {
                        if let timestamp = timestamp as? Timestamp {
                            season.timeUpdated = TimeInterval(timestamp.seconds)
                        }
                        seasons.append(season)
                    } else {
                        print("\nCouldn't get season from: \(document.data())\n")
                    }
                }
                single(.success(seasons))
            }
            return Disposables.create {}
        }
    }

    // get all anime from the given season
    private func getAnime(from season: Season) -> Single<[AnimeSeries]> {
        return Single<[AnimeSeries]>.create { single in
            print("Getting all anime from: \(season.databaseId())")
            let animeRef = self.db.collection(season.databaseId())
            animeRef.getDocuments { (querySnapshot, error) in
                if let error = error {
                    single(.error(FirebaseError.couldNotGetAnime(season: season, error: error)))
                    return
                }

                guard let documents = querySnapshot?.documents else {
                    // MARK: todo -> make error for no documents return for a season getAnime(from season
                    return
                }

                var resultAnimes = [AnimeSeries]()
                for document in documents {
                    do {
                        let animeData = try JSONSerialization.data(withJSONObject: document.data(), options: [])
                        let anime = try JSONDecoder().decode(AnimeSeries.self, from: animeData)
                        resultAnimes.append(anime)
                    } catch {
                        print("\nerror getAnime: ", error)
                    }
                }
                print(season.databaseId(), resultAnimes.count)
                single(.success(resultAnimes))
                return
            }

            return Disposables.create {}
        }
    }

}
