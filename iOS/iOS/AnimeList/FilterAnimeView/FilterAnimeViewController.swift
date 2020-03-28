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
}

class FilterAnimeViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!

    // MARK: - Properties
    let realm = try! Realm()
    weak var delegate: FilterAnimeViewControllerDelegate?
    let viewModel = FilterAnimeViewModel()
    let disposeBag = DisposeBag()

    // MARK:  - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel
            .seasons
            .bind(to: tableView.rx.items(cellIdentifier: "FilterAnimeTableViewCell", cellType: UITableViewCell.self)) { _, element, cell in
                cell.textLabel?.text = "\(element.season) \(element.year)"
                element.selected ? (cell.accessoryType = .checkmark) : (cell.accessoryType = .none)
            }
            .disposed(by: disposeBag)

        tableView.rx.modelSelected(RealmSeason.self)
            .subscribe(onNext: { season in
                // MARK: todo -> add this to operator?
                do {
                    try self.realm.write {
                        season.selected = !season.selected
                    }
                } catch {
                    print(error)
                }
            })
            .disposed(by: disposeBag)
    }

}
