//
//  ViewController.swift
//  iOS
//
//  Created by Steven Berkowitz on R 2/03/20.
//  Copyright © Reiwa 2 nightsquid. All rights reserved.
//

//import Foundation
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

        tableView.delegate = self
        
        navigationItem.title = "AniMusic"
//       nShow warnings navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.titleView = searchBar

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
            .bind(to: tableView.rx.items(cellIdentifier: "AnimeListTableViewCell", cellType: AnimeListTableViewCell.self)) { _, element, cell in
                cell.NameLabel.text = element.name
                cell.formatLabel.text = element.format
                cell.seasonLabel.text = element.season
                cell.yearLabel.text = element.year
            }
            .disposed(by: disposeBag)

        tableView.rx.modelSelected(RealmAnimeSeries.self)
            .filter {
                return $0.songs.count > 0
            }
            .subscribe(onNext: { anime in
                self.navigator.show(segue: .animeSeriesViewController(anime: anime), sender: self)
            })
            .disposed(by: disposeBag)

    }

}

extension AnimeListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
}

