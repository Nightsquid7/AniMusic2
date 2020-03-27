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

protocol FilterAnimeViewControllerDelegate: AnyObject {

}

class FilterAnimeViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    // MARK: - Properties
    weak var delegate: FilterAnimeViewControllerDelegate?
    let viewModel = FilterAnimeViewModel()

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("FilterAnimeViewController")

        viewModel
            .seasons
            .bind(to: tableView.rx.items(cellIdentifier: "FilterAnimeTableViewCell", cellType: UITableViewCell.self)) { _, element, cell in
                cell.textLabel?.text = "\(element.season) \(element.year)"
        }
        .disposed(by: disposeBag)

    }
    

    

}
