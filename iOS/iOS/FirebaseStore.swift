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

    // MARK: - Initialization
    // MARK: todo -> move this to FilterAnimeViewModel?
    // get the list of seasons currently stored in the database
    // Once you get the seasons, Get all the animes for each season
    // Then save to realm
    init() {
        print("firebase store init()")
        let seasonsObservable = Observable.collection(from: realm.objects(RealmSeason.self))
            .filter { $0.count < 1 }
            .flatMap { _ in
                self.getSeasonsList()
            }
            .share()

        // save seasons to realm
        _ = seasonsObservable
            .subscribe(realm.rx.add())
            .disposed(by: disposeBag)

        // search firebase for all Animes in each season colllection,
        // then save to realm
        _ = seasonsObservable
            .flatMap { seasons  in
                Observable.from(seasons)
            }
            .flatMap { season in
                self.getAllAnime(from: season)
            }
            .subscribe(realm.rx.add())
            .disposed(by: disposeBag)

    }

    // get the list of seasons of animes stored in firebase
    private func getSeasonsList() -> Single<[RealmSeason]> {
        return Single<[RealmSeason]>.create { single in
            print("getSeasonsList() -> ")
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
                    }
                }
                single(.success(seasons))
            }
            return Disposables.create {}
        }
    }

    // get all anime from the given season
    func getAllAnime(from season: RealmSeason) -> Single<[RealmAnimeSeries]> {
        return Single<[RealmAnimeSeries]>.create { single in
            print("getAllAnime() -> \(season.season)- \(season.year)")
            let seasonString = season.season + "-" + season.year
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
                // temporary
                // testing how many anime are parsed correctly...
                var animeCount = 0
                var errorCount = 0

                var resultAnimes = [RealmAnimeSeries]()
                for document in documents {

                    do {
                        let animeData = try JSONSerialization.data(withJSONObject: document.data(), options: [])
                        let anime = try JSONDecoder().decode(AnimeSeries.self, from: animeData)
                        let realmAnime = RealmAnimeSeries(from: anime)
                        resultAnimes.append(realmAnime)

                        // temporary
                        animeCount += 1
                    } catch {

                        print(error)
                        errorCount += 1
                    }
                }

                print("animeCount for \(season):  -> \(animeCount)")

                single(.success(resultAnimes))
                return
            }

            return Disposables.create {}
        }
    }

}
