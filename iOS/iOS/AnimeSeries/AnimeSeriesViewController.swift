//
//  AnimeSeriesViewController.swift
//  iOS
//
//  Created by Steven Berkowitz on R 2/03/24.
//  Copyright © Reiwa 2 nightsquid. All rights reserved.
//

import Foundation
import UIKit
import Then
import RxSwift
import RxCocoa
import RxDataSources

class AnimeSeriesViewController: UIViewController, NavigatorViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    // MARK: - Properties
    var viewModel: AnimeSeriesViewModel!
    let navigator = Navigator.sharedInstance

    let disposeBag = DisposeBag()

    static func createWith(storyboard: UIStoryboard, viewModel: AnimeSeriesViewModel) -> AnimeSeriesViewController {
        return (storyboard.instantiateViewController(withIdentifier: "AnimeSeriesViewController") as! AnimeSeriesViewController).then { vc in
            vc.viewModel = viewModel
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = viewModel.anime.name

        let dataSource = RxTableViewSectionedReloadDataSource<AnimeSeriesViewSection>(configureCell: { _, tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AnimeSongTableViewCell", for: indexPath) as? AnimeSongTableViewCell else { return UITableViewCell()}
                cell.nameLabel.text =   item.name
                cell.nameEnglishLabel.text = item.nameEnglish
                cell.relationLabel.text = item.relation


            return cell
        })

        dataSource.titleForHeaderInSection = { dataSource, index in
            return dataSource.sectionModels[index].header
        }

        viewModel.sections
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

    }
}
