//
//  Navigator.swift
//  iOS
//
//  Created by Steven Berkowitz on R 2/03/24.
//  Copyright © Reiwa 2 nightsquid. All rights reserved.
//

import Foundation
import UIKit

class Navigator {

    lazy private var defaultStoryboard = UIStoryboard(name: "Main", bundle: nil)
    static let sharedInstance = Navigator()

    enum Segue {
        case discoverAnimeViewController
        case animeListViewController
        case animeSeriesViewController(anime: RealmAnimeSeries)
        case animeSongViewController
        case songPlayerViewController(song: RealmAnimeSong, source: RealmSongSearchResult)
    }

    func show(segue: Segue, sender: UIViewController) {
        switch segue {
        case .discoverAnimeViewController:
            show(target: DiscoverAnimeViewController.createWith(storyboard: defaultStoryboard), sender: sender)
        case .animeListViewController:
            show(target: AnimeListViewController.createWith(storyboard: defaultStoryboard), sender: sender)
        case .animeSeriesViewController(let anime):
            let viewModel = AnimeSeriesViewModel(with: anime)
            show(target: AnimeSeriesViewController.createWith(storyboard: defaultStoryboard, viewModel: viewModel), sender: sender)
        case .songPlayerViewController(let song, let source):
            print()
            let viewModel = SongPlayerViewModel(song: song, source: source)
            show(target: SongPlayerViewController.createWith(storyboard: defaultStoryboard, viewModel: viewModel), sender: sender)
        default:
            print()
        }
    }

    private func show(target: UIViewController, sender: UIViewController) {
        if let nav = sender as? UINavigationController {
            // push root controller on navigation stack
            nav.pushViewController(target, animated: false)
            return
        }

        if let nav = sender.navigationController {
            // add controller to navigation stack
            nav.pushViewController(target, animated: true)
        } else {
            // present modally
            sender.modalPresentationStyle = .custom

            sender.present(target, animated: true, completion: nil)
        }
    }
}
