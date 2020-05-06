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

    init(frame: CGRect, season: RealmSeason, parentViewController: UIViewController) {
        let view = UIView(frame: frame)
        viewModel = AnimeSeasonViewModel(season: season)
        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        super.init()

        // create spacing at the leftmost part of collection view
        layout.headerReferenceSize = CGSize(width: 10, height: 10)
        layout.footerReferenceSize = CGSize(width: 10, height: 10)
        layout.scrollDirection = .horizontal

        collectionView.register(DiscoverAnimeCollectionViewCell.self, forCellWithReuseIdentifier: "DiscoverAnimeCollectionViewCell")
        collectionView.delegate = self
        collectionView.setCollectionViewLayout(layout, animated: true)
        collectionView.backgroundColor = .white

        viewModel.sections
            .bind(to: collectionView.rx.items(dataSource: viewModel.dataSource))
            .disposed(by: disposeBag)

        collectionView.rx.modelSelected(RealmAnimeSeries.self)
            .subscribe(onNext: { anime in
                // MARK: - todo handle search bar methods...
                print("\(anime.name!) -> \(season.season) \(season.year)")
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
