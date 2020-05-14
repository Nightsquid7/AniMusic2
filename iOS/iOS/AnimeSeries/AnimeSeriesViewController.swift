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
import Kingfisher

class AnimeSeriesViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var seasonLabel: UILabel!
    @IBOutlet weak var formatLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

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

        navigationController?.navigationBar.isHidden = false
        navigationItem.title = viewModel.anime.name

        imageView.setImage(for: viewModel.anime)

        seasonLabel.text = viewModel.anime.season
        formatLabel.text = viewModel.anime.format
        tableView.delegate = self
        // MARK: - todo  -> add this as a static function to AnimeSeriesViewModel
        let dataSource = RxTableViewSectionedReloadDataSource<AnimeSeriesViewSection>(configureCell: { _, tableView, indexPath, item in
            // configure different cells based on item type
            switch item {
            case .DefaultSongItem(let song):
                let cell: AnimeSongTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.configureCell(from: song)
                return cell

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
                case .DefaultSongItem(let song):
                    print("song Default Song Item -> \(song)")
                    // MARK: - todo

                    self.presentActions(for: song)
                }
            })
            .disposed(by: disposeBag)
    }

    func presentActions(for song: RealmAnimeSong) {
        let ac = UIAlertController(title: "Open song", message: "\(song.name!) in", preferredStyle: .actionSheet)
        guard let _ = song.sources.first else {
            ac.addAction(UIAlertAction(title: "No external sources", style: .cancel))
            present(ac, animated: true)
            return
        }
        if let url = URL(string: (song.sources.first?.externalUrl!)!) {
            ac.addAction(UIAlertAction(title: "Spotify", style: .default, handler: { _ in
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }))
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }

 func openSpotify(url: String) {

    }
}

extension AnimeSeriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

}
