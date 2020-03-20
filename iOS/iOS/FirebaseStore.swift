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

struct FirebaseStore {

    static let sharedInstance = FirebaseStore()

    let db = Firestore.firestore()

    func getAnime() -> Single<AnimeSeries> {
        return Single<AnimeSeries>.create { single in

            let animeRef = self.db.collection("Anime")
            animeRef.getDocuments() { (querySnapshot, error) in
                if let error = error {
                    single(.error(error))
                    return
                }

                guard let documents = querySnapshot?.documents else {
                    // MARK: to do -> make error for no documents
                    return
                }

                var animeCount = 0
                var errorCount = 0
                for document in documents {

                    do {
                        let animeData = try JSONSerialization.data(withJSONObject: document.data(), options: [])
                        let anime = try JSONDecoder().decode(AnimeSeries.self, from: animeData)
                        if let songs = anime.songs, songs.count > 0 {
                            _ = songs.map { song in
                                if song.value.sources!.count > 0 {
                                    print("fetched anime: \(anime)")
                                    animeCount += 1
                                }
                            }
                        }

                    } catch {
                        print("couldn't get anime from \(document.data())")
                        print(error)
                        errorCount += 1
                    }
                }
                print("anime.count -> \(animeCount)\nerrorCount -> \(errorCount)")

            }

            return Disposables.create {}
        }
    }

}
