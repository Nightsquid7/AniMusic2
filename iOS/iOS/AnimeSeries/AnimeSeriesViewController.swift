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

class AnimeSeriesViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    // MARK: - Properties
    var viewModel: AnimeSeriesViewModel!
    let navigator = Navigator.sharedInstance

    let disposeBag = DisposeBag()

    // MARK: - initialization
    static func createWith(storyboard: UIStoryboard, viewModel: AnimeSeriesViewModel) -> AnimeSeriesViewController {
        return (storyboard.instantiateViewController(withIdentifier: "AnimeSeriesViewController") as! AnimeSeriesViewController).then { vc in
            vc.viewModel = viewModel
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = viewModel.anime.name
        tableView.delegate = self

        // MARK: - todo  -> add this as a static function to AnimeSeriesViewModel
        let dataSource = RxTableViewSectionedReloadDataSource<AnimeSeriesViewSection>(configureCell: { _, tableView, indexPath, item in
            // configure different cells based on item type
            switch item {
            case .DefaultSongItem(let song):
                let cell: AnimeSongTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.configureCell(name: song.name ?? "whoat",
                                   nameEnglish: song.nameEnglish ?? "name english")
                return cell
            case .SpotifySongItem:
                let cell: SpotifySongTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.configureCell()
                return cell
            default:
                print("default")
                return UITableViewCell()
            }

        })

        dataSource.titleForHeaderInSection = { dataSource, index in
            return dataSource.sectionModels[index].header
        }

        viewModel.sections
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        // navigate to song player view
        tableView.rx.modelSelected(AnimeSeriesViewSection.SectionItem.self)
            .subscribe(onNext: { item in
                switch item {
                case .DefaultSongItem:
                    print("song Default Song Item -> ")
                    // go to song info view

                case .SpotifySongItem(let song, let source):
                    print("SpotifySongItem")
                    self.navigator.show(segue: .songPlayerViewController(song: song, source: source), sender: self)
                default:
                    print("switch default")
                }
            })
            .disposed(by: disposeBag)

    }
}

extension AnimeSeriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

}
