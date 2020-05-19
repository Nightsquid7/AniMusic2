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

    // MARK: - Properties
    var searchController: UISearchController!
    private var resultsTableController: ResultsTableController!

    var filteredAnimes: Results<RealmAnimeSeries>!
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

        resultsTableController =
            self.storyboard?.instantiateViewController(withIdentifier: "ResultsTableController") as? ResultsTableController

        resultsTableController.tableView.delegate = self

        searchController = UISearchController(searchResultsController: resultsTableController)
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.autocapitalizationType = .none
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self // Monitor when the search button is tapped.

        // Place the search bar in the navigation bar.
        navigationItem.searchController = searchController

        view.addSubview(titleLabel)

        view.addSubview(scrollView)

        setConstraints()

        // used as searchController result
        filteredAnimes = realm.objects(RealmAnimeSeries.self)

        // MARK: - todo wait until animes are completed loading...
        // wait until stored anime count  > 190 (approximate account of displayed seasons...)
        let filteredAnimesObservable = Observable.collection(from: filteredAnimes)
            .filter { $0.count > 190 }
            .take(1)

        let seasons = Observable.collection(from: realm.objects(RealmSeason.self))

        // create AnimeSeasonViewManager/collection view
        // for each season.
        _ = Observable.combineLatest(filteredAnimesObservable, seasons)
            .flatMap { _, seasons in
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

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        let scrollViewConstraints = [
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 60),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 10)
        ]

        NSLayoutConstraint.activate(titleLabelConstraints)
        NSLayoutConstraint.activate(scrollViewConstraints)
    }
}

// MARK: - UITableViewDelegate
extension DiscoverAnimeViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedAnime = filteredAnimes[indexPath.row]
        self.navigator.show(segue: .animeSeriesViewController(anime: selectedAnime), sender: self)
    }

     func  tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        print(tableView.estimatedRowHeight)
        return 250
    }
}

// MARK: - UISearchBarDelegate

extension DiscoverAnimeViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        updateSearchResults(for: searchController)
    }

}

// MARK: - UISearchControllerDelegate

// Use these delegate functions for additional control over the search controller.

extension DiscoverAnimeViewController: UISearchControllerDelegate {

    func presentSearchController(_ searchController: UISearchController) {
        Swift.debugPrint("UISearchControllerDelegate invoked method: \(#function).")
    }

    func willPresentSearchController(_ searchController: UISearchController) {
        Swift.debugPrint("UISearchControllerDelegate invoked method: \(#function).")
    }

    func didPresentSearchController(_ searchController: UISearchController) {
        Swift.debugPrint("UISearchControllerDelegate invoked method: \(#function).")
    }

    func willDismissSearchController(_ searchController: UISearchController) {
        Swift.debugPrint("UISearchControllerDelegate invoked method: \(#function).")
    }

    func didDismissSearchController(_ searchController: UISearchController) {
        Swift.debugPrint("UISearchControllerDelegate invoked method: \(#function).")
    }

}

// MARK: - UISearchResultsUpdating
extension DiscoverAnimeViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {

        let searchString = searchController.searchBar.text!

        let namePredicate = NSPredicate(format: "name CONTAINS[c] %@", searchString)
        let filteredAnimes = realm.objects(RealmAnimeSeries.self).filter(namePredicate)

        if let resultsController = searchController.searchResultsController as? ResultsTableController {
            resultsController.filteredAnimes = filteredAnimes
            resultsController.tableView.reloadData()
            self.filteredAnimes = filteredAnimes
        }

    }

}
