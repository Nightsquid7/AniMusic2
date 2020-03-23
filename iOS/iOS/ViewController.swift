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

    let firebaseStore = FirebaseStore.sharedInstance
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

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

    }


}

