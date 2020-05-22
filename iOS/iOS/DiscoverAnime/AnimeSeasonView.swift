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
class AnimeSeasonView: NSObject {
    // MARK: - Properties
    var view = UIView()

    let collectionViewHeight: CGFloat = 235

    lazy var seasonLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    var collectionView: UICollectionView
    let layout = UICollectionViewFlowLayout()

    let navigator = Navigator.sharedInstance
    var viewModel: AnimeSeasonViewModel
    let disposeBag = DisposeBag()

    init(frame: CGRect, season: RealmSeason, parentViewController: UIViewController) {
        view = UIView(frame: frame)
        viewModel = AnimeSeasonViewModel(season: season)
        let collectionViewFrame = CGRect(x: frame.maxX,
                                         y: frame.maxY,
                                         width: frame.width,
                                         height: collectionViewHeight)
        collectionView = UICollectionView(frame: collectionViewFrame, collectionViewLayout: layout)
        super.init()

        view.addSubview(seasonLabel)
        view.addSubview(collectionView)

        seasonLabel.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        seasonLabel.text = season.getTitleString()

        // create spacing at the leftmost part of collection view
        layout.headerReferenceSize = CGSize(width: 10, height: 10)
        layout.footerReferenceSize = CGSize(width: 10, height: 10)
        layout.scrollDirection = .horizontal

        collectionView.register(DiscoverAnimeCollectionViewCell.self, forCellWithReuseIdentifier: "DiscoverAnimeCollectionViewCell")
        collectionView.delegate = self
        collectionView.setCollectionViewLayout(layout, animated: true)
        collectionView.backgroundColor = .white

        setConstraints()

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

    func setConstraints() {
        let seasonLabelConstraints = [
            seasonLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            seasonLabel.heightAnchor.constraint(equalToConstant: 20),
            seasonLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 7)
        ]

        let  collectionViewConstraints = [
            collectionView.topAnchor.constraint(equalTo: seasonLabel.bottomAnchor, constant: 10),
            collectionView.heightAnchor.constraint(equalToConstant: collectionViewHeight),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]

        NSLayoutConstraint.activate(seasonLabelConstraints)
        NSLayoutConstraint.activate(collectionViewConstraints)
    }

}

extension AnimeSeasonView: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: 112, height: collectionViewHeight)
    }

}
