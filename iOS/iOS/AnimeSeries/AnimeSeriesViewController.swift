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

//        nameLabel.text = viewModel.anime.name
//        seasonLabel.text = viewModel.anime.season
//        yearLabel.text = viewModel.anime.year

//        aniDbUriButton.titleLabel?.text = viewModel.anime.aniDbUri
//        aniDbUriButton.rx.tap
//            .subscribe(onNext: { _ in
//                if let uriString = self.viewModel.anime.aniDbUri, let url = URL(string: uriString) {
//                    UIApplication.shared.open(url)
//                }
//            })
//            .disposed(by: disposeBag)


        viewModel.displayedSongs
            .bind(to: tableView.rx.items(cellIdentifier: "AnimeSongTableViewCell", cellType: AnimeSongTableViewCell.self)) { _, element, cell in
                cell.nameLabel.text = element.name
                cell.nameEnglishLabel.text = element.nameEnglish
                cell.relationLabel.text = element.relation
                let ranges = element.ranges
                if let start = ranges.first?.start.value {

                    cell.startLabel.text = String(start)
                } else { print("no start range")}
                if let end = element.ranges.first?.end.value {
                    cell.startLabel.text = String(end)
                } else { print("no end range")}
           }
           .disposed(by: disposeBag)

    }

}
