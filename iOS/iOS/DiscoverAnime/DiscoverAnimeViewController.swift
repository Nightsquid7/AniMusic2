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
import RxDataSources

class DiscoverAnimeViewController: UIViewController {

    // MARK: - Properties
    var animeSeasonsTableView = UITableView()
    var viewModel = DiscoverAnimeViewModel()
    var searchController: UISearchController!
    private var resultsTableController: ResultsTableController!
    // This is the total height for every animeSeasonView
    let animeSeasonViewHeight: CGFloat = 313

    var filteredAnimes: Results<RealmAnimeSeries>!
    let navigator = Navigator.sharedInstance

    let realm = try! Realm()
    let disposeBag = DisposeBag()

    // MARK: - createWith(storyboard: UIStoryboard)
    static func createWith(storyboard: UIStoryboard) -> DiscoverAnimeViewController {
        return storyboard.instantiateViewController(withIdentifier: "DiscoverAnimeViewController") as! DiscoverAnimeViewController
    }

    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.topItem?.title = "Discover"
        self.navigationController?.navigationBar
            .prefersLargeTitles = true

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
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.animeSeasonsTableView.delegate = self
        view.addSubview(animeSeasonsTableView)
        setConstraints()

        // used as searchController result
        filteredAnimes = realm.objects(RealmAnimeSeries.self)

        animeSeasonsTableView.register(AnimeSeasonTableCell.self, forCellReuseIdentifier: "AnimeSeasonTableCell")

        let  dataSource = RxTableViewSectionedReloadDataSource<DiscoverAnimeSeasonViewSection>(configureCell: { dataSource, tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: "AnimeSeasonTableCell", for: indexPath) as! AnimeSeasonTableCell
            cell.configureCell(season: item, parentViewController: self)
            return cell
        })

        viewModel.sections
            .bind(to: animeSeasonsTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

    }

    func setConstraints() {
        animeSeasonsTableView.translatesAutoresizingMaskIntoConstraints = false
        let tableViewConstraints = [
            animeSeasonsTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            animeSeasonsTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 7),
            animeSeasonsTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -7),
            animeSeasonsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 10)
        ]

        NSLayoutConstraint.activate(tableViewConstraints)
    }
}

// MARK: - UITableViewDelegate
extension DiscoverAnimeViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView === resultsTableController.tableView {
            let selectedAnime = filteredAnimes[indexPath.row]
            self.navigator.show(segue: .animeSeriesViewController(anime: selectedAnime), sender: self)
        }
    }

     func  tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView === resultsTableController.tableView {
            return 190
        }
        if tableView === self.animeSeasonsTableView {
            return self.animeSeasonViewHeight
        }

        return 0
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

