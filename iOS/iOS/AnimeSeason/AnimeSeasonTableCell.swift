//
//  AnimeSeasonTableCell.swift
//  iOS
//
//  Created by Steven Berkowitz on R 2/04/09.
//  Copyright © Reiwa 2 nightsquid. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 Arranges all animes of season inside a collection view
 */
class AnimeSeasonTableCell: UITableViewCell {
    // MARK: - Properties
    let collectionViewHeight: CGFloat = 235
    let collectionViewWidth: CGFloat = 112

    // TODO: Add dynamic text support
    lazy var seasonLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    var collectionView: UICollectionView!
    let layout = UICollectionViewFlowLayout()

    let navigator = Navigator.sharedInstance
    var viewModel: AnimeSeasonViewModel!
    let disposeBag = DisposeBag()

    // MARK: - Functions
    func  configureCell(season: RealmSeason, parentViewController: UIViewController) {
        viewModel = AnimeSeasonViewModel(season: season)
        setUpSeasonLabel(season: season)
        setUpCollectionView()
        setUpLayout()
        setUpContentView()
        setUpConstraints()
        setUpViewModelDataSource(parentViewController: parentViewController)
    }

    func setUpCollectionView() {
        let collectionViewFrame = CGRect(x: frame.maxX,
                                         y: frame.maxY,
                                         width: frame.width,
                                         height: collectionViewHeight)
        collectionView = UICollectionView(frame: collectionViewFrame, collectionViewLayout: layout)

        collectionView.register(AnimeSeasonCollectionViewCell.self, forCellWithReuseIdentifier: "AnimeSeasonCollectionViewCell")
        collectionView.delegate = self
        collectionView.setCollectionViewLayout(layout, animated: true)
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
    }

    func setUpLayout() {
        // create spacing at the leftmost part of collection view
        layout.headerReferenceSize = CGSize(width: 10, height: 10)
        layout.footerReferenceSize = CGSize(width: 10, height: 10)
        layout.scrollDirection = .horizontal
    }
    func setUpSeasonLabel(season: RealmSeason) {
        seasonLabel.translatesAutoresizingMaskIntoConstraints = false
        seasonLabel.text = season.titleString()
    }

    func setUpContentView() {
        contentView.addSubview(seasonLabel)
        contentView.addSubview(collectionView)
    }

    func setUpConstraints() {
        let seasonLabelConstraints = [
            seasonLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            seasonLabel.heightAnchor.constraint(equalToConstant: 20),
            seasonLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 7)
        ]

        let  collectionViewConstraints = [
            collectionView.topAnchor.constraint(equalTo: seasonLabel.bottomAnchor, constant: 10),
            collectionView.heightAnchor.constraint(equalToConstant: collectionViewHeight),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ]

        NSLayoutConstraint.activate(seasonLabelConstraints)
        NSLayoutConstraint.activate(collectionViewConstraints)
    }

    func setUpViewModelDataSource(parentViewController: UIViewController) {
        viewModel.sections
            .bind(to: collectionView.rx.items(dataSource: viewModel.dataSource))
            .disposed(by: disposeBag)

        // select and navigate to a specific anime series
        collectionView.rx.modelSelected(RealmAnimeSeries.self)
            .subscribe(onNext: { anime in
                self.navigator.show(segue: .animeSeriesViewController(anime: anime), sender: parentViewController)
            })
            .disposed(by: disposeBag)
    }

}

extension AnimeSeasonTableCell: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionViewWidth, height: collectionViewHeight)
    }

}
