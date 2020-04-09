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
import RealmSwift

class DiscoverAnimeViewController: UIViewController {
    // MARK: - Views
    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 150))
        label.text = "Discover"
        label.font = label.font.withSize(42)

        return label
    }()

    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
        return searchBar
    }()

    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        return scrollView
    }()

    // MARK: - Properties
    let navigator = Navigator.sharedInstance
    let seasonViewHeight: CGFloat = 200
    let realm = try! Realm()
    let disposeBag = DisposeBag()

    static func createWith(storyboard: UIStoryboard) -> DiscoverAnimeViewController {
        return storyboard.instantiateViewController(withIdentifier: "DiscoverAnimeViewController") as! DiscoverAnimeViewController
    }

    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.isHidden = true

        view.addSubview(titleLabel)
        view.addSubview(searchBar)
        view.addSubview(scrollView)

        setConstraints()

        let seasons = realm.objects(RealmSeason.self).sorted(byKeyPath: "season")

        seasons.forEach { season in
            let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: seasonViewHeight))
            _ = AnimeSeasonViewManager(parentView: view, season: RealmSeason(season: season.season, year: season.year), parentViewController: self)
              scrollView.addSubview(view)
        }

    }

    func setConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let titleLabelConstraints = [
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20)
        ]

        searchBar.translatesAutoresizingMaskIntoConstraints = false
        let searchBarConstraints = [
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            searchBar.widthAnchor.constraint(equalToConstant: view.frame.width - 40),
            searchBar.heightAnchor.constraint(equalToConstant: 50)
        ]

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        let scrollViewConstraints = [
            scrollView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
//            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            scrollView.widthAnchor.constraint(equalToConstant: view.frame.width),
            scrollView.heightAnchor.constraint(equalToConstant: view.frame.height)
        ]

        NSLayoutConstraint.activate(titleLabelConstraints)
        NSLayoutConstraint.activate(searchBarConstraints)
        NSLayoutConstraint.activate(scrollViewConstraints)
    }
}

extension DiscoverAnimeViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 112, height: 200)
    }

}
