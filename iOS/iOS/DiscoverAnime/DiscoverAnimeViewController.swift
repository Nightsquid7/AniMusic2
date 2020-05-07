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

    // want to dynamically add AnimeSeason views to the stack you
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: seasonViewHeight * 3))
        stackView.axis = .vertical

        return stackView
    }()

//    var animeSeasonView: AnimeSeasonViewManager?
//    var animeSeasonView2: AnimeSeasonViewManager?
//    var animeSeasonView3: AnimeSeasonViewManager?

    // MARK: - Properties
    let navigator = Navigator.sharedInstance
    let seasonViewHeight: CGFloat = 200
    let realm = try! Realm()
    let disposeBag = DisposeBag()

    // MARK: - createWith(storyboard: UIStoryboard)
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

        _ = Observable.collection(from: realm.objects(RealmSeason.self))
            .flatMap { seasons in
                Observable.from(Array(seasons))
            }
            .enumerated()
            .map { index, season in
                print("index, season -> \(index), \(season)")
                // set up an AnimeSeasonView
                let frame = CGRect(x: 0, y: self.seasonViewHeight * CGFloat(index),
                                   width: self.view.frame.width,
                                   height: self.seasonViewHeight)
                let animeSeasonView = AnimeSeasonViewManager(frame: frame, season: season, parentViewController: self)
                let seasonsView = animeSeasonView.collectionView
                self.scrollView.addSubview(seasonsView)
                self.scrollView.contentSize.height += seasonsView.frame.height + 10
            }
            .subscribe()
            .disposed(by: disposeBag)

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
            scrollView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 10)
        ]

        NSLayoutConstraint.activate(titleLabelConstraints)
        NSLayoutConstraint.activate(searchBarConstraints)
        NSLayoutConstraint.activate(scrollViewConstraints)
    }
}
