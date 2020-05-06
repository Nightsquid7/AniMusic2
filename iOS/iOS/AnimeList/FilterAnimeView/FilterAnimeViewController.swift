//
//  FilterAnimeViewController.swift
//  iOS
//
//  Created by Steven Berkowitz on R 2/03/26.
//  Copyright © Reiwa 2 nightsquid. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RealmSwift
import RxRealm

protocol FilterAnimeViewControllerDelegate: AnyObject {
    // MARK: todo -> send filter predicate back to AnimeListViewController
//    func getPredicateFromSelection() -> NSPredicate.
}

class FilterAnimeViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filterButton: UIButton!

    // MARK: - Properties
    let realm = try! Realm()
    weak var delegate: FilterAnimeViewControllerDelegate?
    let viewModel = FilterAnimeViewModel()
    let disposeBag = DisposeBag()

    // MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()

        // bind each season in viewModel to a table view cell
        viewModel
            .seasons
            .bind(to: tableView.rx.items(cellIdentifier: "FilterAnimeTableViewCell", cellType: UITableViewCell.self)) { _, element, cell in
                cell.textLabel?.text = "\(element.season) \(element.year)"
                element.selected ? (cell.accessoryType = .checkmark) : (cell.accessoryType = .none)
            }
            .disposed(by: disposeBag)

        // when the user taps a cell (with season info) -> toggle that cell
        // and save to Realm
        tableView.rx.modelSelected(RealmSeason.self)
            .subscribe(onNext: { season in
                // is this write ok to be here in the FilterAnimeViewController?/ can it go in the viewModel?
                //
                do {
                    try self.realm.write {
                        season.selected = !season.selected
                    }
                } catch {
                    print(error)
                }
            })
            .disposed(by: disposeBag)

        filterButton.rx.tap
            .subscribe(onNext: {
                print("filter animes Button tap")
                self.dismiss(animated: true, completion: nil)
            })
        .disposed(by: disposeBag)
    }
}

// MARK: - FilterAnimeViewControllerDelegate
extension FilterAnimeViewController: FilterAnimeViewControllerDelegate {
//    func getPredicateFromSelection() -> NSPredicate {
//        let
//    }

}
