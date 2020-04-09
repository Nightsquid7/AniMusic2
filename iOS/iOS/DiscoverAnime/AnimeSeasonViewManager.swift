//
//  AnimeSeasonViewController.swift
//  iOS
//
//  Created by Steven Berkowitz on R 2/04/09.
//  Copyright © Reiwa 2 nightsquid. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

// holds collection view, and manages AnimeSeasonViewModel
class AnimeSeasonViewManager: NSObject {
    // MARK: - Properties
    var collectionView: UICollectionView
    let layout = UICollectionViewFlowLayout()

    let navigator = Navigator.sharedInstance
    var viewModel: AnimeSeasonViewModel
    let disposeBag = DisposeBag()

    init(parentView: UIView, season: RealmSeason, parentViewController: UIViewController) {
        viewModel = AnimeSeasonViewModel(season: season)
        collectionView = UICollectionView(frame: parentView.frame, collectionViewLayout: layout)
        super.init()

        // create spacing at the leftmost part of collection view
        layout.headerReferenceSize = CGSize(width: 10, height: 10)
        layout.scrollDirection = .horizontal

        collectionView.register(DiscoverAnimeCollectionViewCell.self, forCellWithReuseIdentifier: "DiscoverAnimeCollectionViewCell")
        collectionView.delegate = self
        collectionView.setCollectionViewLayout(layout, animated: true)
        parentView.addSubview(collectionView)

        viewModel.sections
            .bind(to: collectionView.rx.items(dataSource: viewModel.dataSource))
            .disposed(by: disposeBag)

        collectionView.rx.modelSelected(RealmAnimeSeries.self)
            .subscribe(onNext: { anime in
                print(anime.name ?? "no name...")
                // MARK: - todo handle search bar methods...
                print("ANIME SEASON VIEW MANAGER")
                self.navigator.show(segue: .animeSeriesViewController(anime: anime), sender: parentViewController)
            })
            .disposed(by: disposeBag)

    }

}

extension AnimeSeasonViewManager: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 112, height: 200)
    }

}

