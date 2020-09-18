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

/**
 Displays all seasons of anime using a table view.
 The cells of the table view each contain a collection view,
 The cells of the collection view each contain an anime
*/
class DiscoverAnimeViewController: UIViewController {

    // MARK: - Properties
    var animeSeasonsTableView = UITableView()
    var viewModel = DisplayAnimeViewModel()

    var searchController: UISearchController!
    private var resultsTableController: ResultsTableController!
    // This is the total height for every animeSeasonView
    let animeSeasonViewHeight: CGFloat = 313

    let navigator = Navigator.sharedInstance
    let realm = try! Realm()
    let disposeBag = DisposeBag()

    // MARK: - Functions
    static func createWith(storyboard: UIStoryboard) -> DiscoverAnimeViewController {
        return storyboard.instantiateViewController(withIdentifier: "DiscoverAnimeViewController") as! DiscoverAnimeViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpResultsController()
        setUpSearchController()
        setUpNavigationController()
        setUpNavigationItem()
        setUpAnimeSeasonsTableView()
        setUpConstraints()
        setUpViewModelDataSource()
    }

    func setUpResultsController() {
        resultsTableController = self.storyboard?.instantiateViewController(withIdentifier: "ResultsTableController") as? ResultsTableController
        resultsTableController.tableView.delegate = self
    }

    func setUpSearchController() {
        searchController = UISearchController(searchResultsController: resultsTableController)
        searchController.searchResultsUpdater = self
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.placeholder = "Search Animes"
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }

    func setUpNavigationController() {
        self.navigationController?.navigationBar.topItem?.title = "AniMusic"
    }

    func setUpNavigationItem() {
        // Place the search bar in the navigation bar.
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }

    func setUpAnimeSeasonsTableView() {
        self.animeSeasonsTableView.delegate = self
        view.addSubview(animeSeasonsTableView)
        animeSeasonsTableView.register(AnimeSeasonTableCell.self, forCellReuseIdentifier: "AnimeSeasonTableCell")
    }

    func setUpViewModelDataSource() {
        // Setting up dataSource here to get reference
        // to parentViewController for navigation
        let dataSource = RxTableViewSectionedReloadDataSource<DisplayAnimeSeasonViewSection>(configureCell: { _, tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: "AnimeSeasonTableCell", for: indexPath) as! AnimeSeasonTableCell
            cell.configureCell(season: item, parentViewController: self)
            cell.selectionStyle = .none
            return cell
        })

        viewModel.sections
            .bind(to: animeSeasonsTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }

    func setUpConstraints() {
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
            let selectedAnime = resultsTableController.filteredAnimes[indexPath.row]
            self.navigator.show(segue: .animeSeriesViewController(anime: selectedAnime), sender: self)
        }
    }

     func  tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView === resultsTableController.tableView { return 190 }
        if tableView === self.animeSeasonsTableView { return self.animeSeasonViewHeight }
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

// MARK: - UISearchResultsUpdating
extension DiscoverAnimeViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchString = searchController.searchBar.text!
        let namePredicate = NSPredicate(format: "name CONTAINS[c] %@", searchString)
        let filteredAnimes = realm.objects(RealmAnimeSeries.self).filter(namePredicate)

        if let resultsController = searchController.searchResultsController as? ResultsTableController {
            resultsController.filteredAnimes = filteredAnimes
            resultsController.tableView.reloadData()
        }
    }
}
