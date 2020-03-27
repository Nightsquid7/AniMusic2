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

struct FirebaseStore {
    // MARK: - Properties
    let realm = try! Realm()
    static let sharedInstance = FirebaseStore()
    let db = Firestore.firestore()

    enum FirebaseError: Error {
        case couldNotGetAnime(_ error: Error)
        case couldNotGetSeason(_ error: Error)
    }

    // MARK:  - Initialization
    init() {
        //  -> move this to FilterAnimeViewModel?
        if realm.objects(RealmSeason.self).count == 0 {
            let realm = try! Realm()
            _ = getSeasonsList()
                .map { seasonsArray in
                    try? realm.write {
                        realm.add(seasonsArray)
                    }
                }
                .subscribe({ next in
                    print("next", next)
                })
        } else {
            print("realm have seasons: \(realm.objects(RealmSeason.self))")
        }

    }
    // get the list of seasons of animes stored in firebase
    private func getSeasonsList() -> Single<[RealmSeason]> {
        return Single<[RealmSeason]>.create { single in

            let seasonRef = self.db.collection("Seasons-List")
            seasonRef.getDocuments() { (querySnapshot, error) in
                if let error = error {
                    single(.error(FirebaseError.couldNotGetSeason(error)))
                    return
                }

                guard let documents = querySnapshot?.documents else { return }

                var seasons = [RealmSeason]()
                for document in documents {
                    let seasonData = try? JSONSerialization.data(withJSONObject: document.data(), options: [])
                    if let season = try? JSONDecoder().decode(RealmSeason.self, from: seasonData!) {
                        print(season)
                        seasons.append(season)
                    }
                }
                single(.success(seasons))
            }
            return Disposables.create {}
        }
    }


    func getAnime(for season: String) -> Single<[RealmAnimeSeries]> {
        return Single<[RealmAnimeSeries]>.create { single in

            let animeRef = self.db.collection(season)
            animeRef.getDocuments() { (querySnapshot, error) in
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
                        print("couldn't get anime from \(document.data())")
                        print(error)
                        errorCount += 1
                    }
                }

                single(.success(resultAnimes))
                return
            }

            return Disposables.create {}
        }
    }

}
