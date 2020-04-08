//
//  DiscoverAnimeViewController.swift
//  iOS
//
//  Created by Steven Berkowitz on R 2/04/07.
//  Copyright © Reiwa 2 nightsquid. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DiscoverAnimeViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!

    // MARK: - Properties
    let navigator = Navigator.sharedInstance
    let viewModel = DiscoverAnimeViewModel()
    let disposeBag = DisposeBag()

    let layout = UICollectionViewFlowLayout()

    static func createWith(storyboard: UIStoryboard) -> DiscoverAnimeViewController {
        return storyboard.instantiateViewController(withIdentifier: "DiscoverAnimeViewController") as! DiscoverAnimeViewController
    }

    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        // create spacing at the leftmost part of collection view
        layout.headerReferenceSize = CGSize(width: 10, height: 10)
        layout.scrollDirection = .horizontal

        collectionView.delegate = self
        collectionView.setCollectionViewLayout(layout, animated: true)

        viewModel.sections
            .bind(to: collectionView.rx.items(dataSource: viewModel.dataSource))
            .disposed(by: disposeBag)

        collectionView.rx.modelSelected(RealmAnimeSeries.self)
            .subscribe(onNext: { anime in
                print(anime.name ?? "no name...")
                self.navigator.show(segue: .animeSeriesViewController(anime: anime), sender: self)
            })
            .disposed(by: disposeBag)
    }

}

extension DiscoverAnimeViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 112, height: 200)
    }

}
