//
//  ViewController.swift
//  iOS
//
//  Created by Steven Berkowitz on R 2/03/20.
//  Copyright © Reiwa 2 nightsquid. All rights reserved.
//

import UIKit
import FirebaseFirestore
import RxSwift
import RxCocoa
import RealmSwift


class AnimeListViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    let viewModel = AnimeListViewModel()
    let navigator = Navigator.sharedInstance

    let firebaseStore = FirebaseStore.sharedInstance
    let disposeBag = DisposeBag()

    static func createWith(storyboard: UIStoryboard) -> AnimeListViewController {
        return storyboard.instantiateViewController(withIdentifier: "AnimeListViewController") as! AnimeListViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "AniMusic"
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: searchBar)

        searchBar.rx.textDidBeginEditing
            .subscribe(onNext: {
                self.searchBar.showsCancelButton = true
                self.searchBar.showsScopeBar = true
            })
            .disposed(by: disposeBag)

        searchBar.rx.text
            .orEmpty
            .subscribe(onNext: {
                self.viewModel.filterResults(with: $0)
            })
            .disposed(by: disposeBag)

        searchBar.rx.searchButtonClicked
            .subscribe(onNext: {
                self.searchBar.resignFirstResponder()
            })
            .disposed(by: disposeBag)

        searchBar.rx.cancelButtonClicked
            .subscribe(onNext:  {
                self.searchBar.text = ""
                self.searchBar.showsCancelButton = false
                self.searchBar.showsScopeBar = true
                self.searchBar.resignFirstResponder()
            })
            .disposed(by: disposeBag)

        viewModel.displayedAnimes
            .bind(to: tableView.rx.items(cellIdentifier: "AnimeCell", cellType: UITableViewCell.self)) { _, element, cell in
                    cell.textLabel?.text = element.name
            }
            .disposed(by: disposeBag)

        tableView.rx.modelSelected(RealmAnimeSeries.self)
            .subscribe(onNext: { anime in
                self.navigator.show(segue: .animeSeriesViewController(anime: anime), sender: self)
            })
            .disposed(by: disposeBag)

    }


}

