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
    // MARK: - IBOutlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    // MARK: - Properties
    let viewModel = AnimeListViewModel()
    let navigator = Navigator.sharedInstance

    private weak var slideInTransitioningDelegate = SlideInPresentationManager()

    let firebaseStore = FirebaseStore.sharedInstance
    let disposeBag = DisposeBag()

    static func createWith(storyboard: UIStoryboard) -> AnimeListViewController {
        return storyboard.instantiateViewController(withIdentifier: "AnimeListViewController") as! AnimeListViewController
    }
    // MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self

        navigationItem.title = "AniMusic"

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
            .subscribe(onNext: {
                self.searchBar.text = ""
                self.searchBar.showsCancelButton = false
                self.searchBar.showsScopeBar = true
                self.searchBar.resignFirstResponder()
            })
            .disposed(by: disposeBag)

        viewModel.displayedAnimes
            .bind(to: tableView.rx.items(cellIdentifier: "AnimeListTableViewCell", cellType: AnimeListTableViewCell.self)) { _, element, cell in
                cell.nameLabel.text = element.name
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

    // MARK: - ViewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }

    }
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? FilterAnimeViewController {
            controller.delegate = self
            controller.transitioningDelegate = slideInTransitioningDelegate
            controller.modalPresentationStyle = .custom
        }
    }

}

// MARK: - FilterAnimeViewControllerDelegate
extension AnimeListViewController: FilterAnimeViewControllerDelegate {

}

// MARK: - UITableViewDelegate
extension AnimeListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // MARK: todo -> get proper tableView height
        return 160
   }
}
