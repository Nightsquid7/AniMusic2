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
    // MARK: - Views
    lazy var imageView: UIImageView = {
        var imageView = UIImageView()
        return imageView
    }()

    lazy var seasonLabel: UILabel = {
        var label = UILabel()
        return label
    }()
    lazy var formatLabel: UILabel = {
        var label = UILabel()
        return label
    }()

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()

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

        imageView.setImage(for: viewModel.anime)

        seasonLabel.text = viewModel.anime.season
        formatLabel.text = viewModel.anime.format

        tableView.delegate = self
        tableView.register(AnimeSongTableViewCell.self, forCellReuseIdentifier: "AnimeSongTableViewCell")

        setConstraints()

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

    func setConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        seasonLabel.translatesAutoresizingMaskIntoConstraints = false
        formatLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(imageView)
        view.addSubview(seasonLabel)
        view.addSubview(formatLabel)
        view.addSubview(tableView)

        let imageViewConstraints = [
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 14),
            imageView.heightAnchor.constraint(equalToConstant: 200),
            imageView.widthAnchor.constraint(equalToConstant: 140)
        ]

        let seasonLabelConstraints = [
            seasonLabel.bottomAnchor.constraint(equalTo: formatLabel.topAnchor, constant: -20),
            seasonLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10),
            seasonLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -5)
        ]

        let formatLabelConstraints = [
            formatLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            formatLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10)
        ]

        let tableViewConstraints = [
            tableView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ]

        NSLayoutConstraint.activate(imageViewConstraints)
        NSLayoutConstraint.activate(seasonLabelConstraints)
        NSLayoutConstraint.activate(formatLabelConstraints)
        NSLayoutConstraint.activate(tableViewConstraints)
        print(tableView.frame)
    }

    func presentActions(for song: RealmAnimeSong) {
        let anime = viewModel.anime
        let titleString = "\(anime.name ?? ""): \(song.name ?? "")"
        let ac = UIAlertController(title: titleString, message: "", preferredStyle: .actionSheet)
        var supportedSources = ["Spotify"]

        for source in song.sources {
            if let url = URL(string: String(source.externalUrl ?? "")), let sourceName = source.source {
                ac.addAction(UIAlertAction(title: "Open in \(sourceName)", style: .default, handler: { _ in
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }))

                supportedSources.removeAll(where: { $0 == sourceName })
            } else {
                print("\ncould not add source: \(source)")
            }
        }
        addGooglePlayAction(to: ac, songName: song.name, animeName: anime.name)
        addYoutubeAction(to: ac, songName: song.name, animeName: anime.name)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }

    // MARK: - todo At this to AnimeSeriesViewModel
    // MARK: - todo Add Source -> so that this function can run for every source
    // add an action that opens link to Google Play
    func addGooglePlayAction(to ac: UIAlertController, songName: String!, animeName: String!) {
        guard let songName = songName, let animeName = animeName else { return }
        let formattedSongName = songName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let formattedAnimeName = animeName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let queryString = formattedSongName + "%20" + formattedAnimeName
        // // MARK: - todo
        // Get country code
        if let url = URL(string: "https://play.google.com/store/search?q=\(queryString)&c=music&hl=en") {
            ac.addAction(UIAlertAction(title: "Open in google play", style: .default, handler: { _ in
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }))
        } else { print("could not get url for google play store\n\(queryString))")}
    }
    func addYoutubeAction(to ac: UIAlertController, songName: String!, animeName: String!) {
        guard let songName = songName, let animeName = animeName else { return }
        let formattedSongName = songName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let formattedAnimeName = animeName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let queryString = formattedSongName + "%20" + formattedAnimeName
        // // MARK: - todo
        // Get country code
        if let url = URL(string: "https://www.youtube.com/results?search_query=\(queryString)") {
            ac.addAction(UIAlertAction(title: "Open in Youtube", style: .default, handler: { _ in
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }))
        } else { print("could not get url for Youtube\n\(queryString))")}
    }
}

extension AnimeSeriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

}
