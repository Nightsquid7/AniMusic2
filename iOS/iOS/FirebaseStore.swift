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

class FirebaseStore {
    // MARK: - Properties
    let realm = try! Realm()
    static let sharedInstance = FirebaseStore()
    let db = Firestore.firestore()
    let disposeBag = DisposeBag()

    enum FirebaseError: Error {
        case couldNotGetAnime(_ error: Error)
        case couldNotGetSeason(_ error: Error)
    }

    // Downloads/save seasons from the database that have not been saved locally
    public func updateLocalRealm() {
        let locallyStoredSeasons = Observable.collection(from: realm.objects(RealmSeason.self)).take(1)

        let seasonsInFirebase = getSeasonsListFromFireStore()
            .asObservable()
            .share()

        // search firebase for all Animes in each season colllection,
        let seasonsToDownload = Observable.combineLatest(locallyStoredSeasons, seasonsInFirebase)
            .map { locallyStoredSeasons, seasonsInFirebase  -> [RealmSeason] in
                let localSeasonNames = locallyStoredSeasons.map { $0.getTitleString() }
                return seasonsInFirebase.compactMap { seasonInFirebase in
                    if localSeasonNames.contains(seasonInFirebase.getTitleString()) {
                        return nil
                    }
                    print("newSeason \(seasonInFirebase.getTitleString())")
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

        let downloadedAnimes = seasonsToDownload
            .flatMap { season in
                self.getAnime(from: season)
            }

        // save animes to Realm
        downloadedAnimes
            .subscribe(realm.rx.add())
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
    private func getSeasonsListFromFireStore() -> Single<[RealmSeason]> {
        return Single<[RealmSeason]>.create { single in
            let seasonRef = self.db.collection("Seasons-List")
            seasonRef.getDocuments { (querySnapshot, error) in
                if let error = error {
                    single(.error(FirebaseError.couldNotGetSeason(error)))
                    return
                }
                guard let documents = querySnapshot?.documents else { return }
                var seasons = [RealmSeason]()
                for document in documents {
                    let seasonData = try? JSONSerialization.data(withJSONObject: document.data(), options: [])
                    if let season = try? JSONDecoder().decode(RealmSeason.self, from: seasonData!) {
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
    private func getAnime(from season: RealmSeason) -> Single<[RealmAnimeSeries]> {
        return Single<[RealmAnimeSeries]>.create { single in
            let seasonString = season.season + "-" + season.year
            print("Getting all anime from: \(seasonString)")
            let animeRef = self.db.collection(seasonString)
            animeRef.getDocuments { (querySnapshot, error) in
                if let error = error {
                    single(.error(FirebaseError.couldNotGetAnime(error)))
                    return
                }

                guard let documents = querySnapshot?.documents else {
                    // MARK: todo -> make error for no documents
                    return
                }

                var resultAnimes = [RealmAnimeSeries]()
                for document in documents {
                    do {
                        let animeData = try JSONSerialization.data(withJSONObject: document.data(), options: [])
                        let anime = try JSONDecoder().decode(AnimeSeries.self, from: animeData)
                        let realmAnime = RealmAnimeSeries(from: anime)
                        resultAnimes.append(realmAnime)
                    } catch {
                        print("\nerror getAnime: ", error)
                    }
                }

                single(.success(resultAnimes))
                return
            }

            return Disposables.create {}
        }
    }

}
