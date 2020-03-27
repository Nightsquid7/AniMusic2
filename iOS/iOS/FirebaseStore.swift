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
    let realm = try! Realm()

    static let sharedInstance = FirebaseStore()

    let db = Firestore.firestore()

    // currently only getting anime is from "Anime" collection
    // MARK: todo -> add season
    func getAnime(for season: String) -> Single<[RealmAnimeSeries]> {
        return Single<[RealmAnimeSeries]>.create { single in

            let animeRef = self.db.collection(season)
            animeRef.getDocuments() { (querySnapshot, error) in
                if let error = error {
                    single(.error(error))
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
