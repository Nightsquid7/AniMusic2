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

    var filteredAnimesObservable: Observable<Results<RealmAnimeSeries>>!

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

        animeSeasonsTableView.register(AnimeSeasonTableCell.self, forCellReuseIdentifier: "AnimeSeasonTableCell")

        let dataSource = RxTableViewSectionedReloadDataSource<DiscoverAnimeSeasonViewSection>(configureCell: { _ , tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: "AnimeSeasonTableCell", for: indexPath) as! AnimeSeasonTableCell
            cell.configureCell(season: item, parentViewController: self)
            cell.selectionStyle = .none
            return cell
        })

        viewModel.sections
            .bind(to: animeSeasonsTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        filteredAnimesObservable = Observable.collection(from: realm.objects(RealmAnimeSeries.self))

       let predicateObservable = searchController.searchBar.rx.text
           .compactMap { $0 }
           .filter { !$0.isEmpty }
           .map {NSPredicate(format: "name CONTAINS[c] %@", $0) }

        // Show the user a message if the anime isn't present
        // Give them a chance to reload the database
        _ = Observable.combineLatest(filteredAnimesObservable, predicateObservable)
            .map { animes, predicate in
                animes.filter(predicate)
            }
            .debounce(.seconds(2), scheduler: MainScheduler.instance)
            .filter { $0.count < 1 }
            .subscribe(onNext: { _ in
                self.present(self.alertController, animated: true)
            })
            .disposed(by: disposeBag)

        // set up alertController
        self.alertController.addAction(UIAlertAction(title: "Reload the database", style: .default, handler: { _ in
            let store = FirebaseStore()
            store.removeDefaultRealm()
            store.loadAllData()
            self.searchController.searchBar.text = ""
            self.searchController.searchBar.resignFirstResponder()
            self.animeSeasonsTableView.reloadData()
            }))

        self.alertController.addAction(UIAlertAction(title: "Send Email", style: .default, handler: { _ in
            let email = "animemusicapp7@gmail.com"
            guard let url = URL(string: "mailto:\(email)") else { return }
            UIApplication.shared.open(url)
        }))

        self.alertController.addAction(UIAlertAction(title: "Back to Search", style: .cancel))
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

    // MARK: - alertController -> present anime is not found alert
    let alertController = UIAlertController(title: "Didn't find what you're looking for?",
                                            message: "We have just started adding animes to the database..\nTry reloading the database, or request a season",
                                            preferredStyle: .actionSheet)

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

// MARK: - UISearchResultsUpdating
extension DiscoverAnimeViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {

        let searchString = searchController.searchBar.text!

        let namePredicate = NSPredicate(format: "name CONTAINS[c] %@", searchString)
        let filteredAnimes = realm.objects(RealmAnimeSeries.self).filter(namePredicate)

        if let resultsController = searchController.searchResultsController as? ResultsTableController {
            resultsController.filteredAnimes = filteredAnimes
            resultsController.tableView.reloadData()

//            filteredAnimesObservable.filter(namePredicate)
        }

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
