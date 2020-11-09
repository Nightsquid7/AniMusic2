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
        case tabBarController
        case displayAnimeViewController
        case animeSeriesViewController(anime: AnimeSeries)
        case webViewViewController(url: URL)
    }

    func show(segue: Segue, sender: UIViewController) {
        switch segue {
        case .tabBarController:
            show(target: TabBarController.createWith(storyboard: defaultStoryboard), sender: sender)
        case .displayAnimeViewController:
            show(target: DisplayAnimeViewController.createWith(storyboard: defaultStoryboard), sender: sender)
        case .animeSeriesViewController(let anime):
            let viewModel = AnimeSeriesViewModel(with: anime)
            show(target: AnimeSeriesViewController.createWith(storyboard: defaultStoryboard, viewModel: viewModel), sender: sender)
        case .webViewViewController(let url):
            show(target: WebViewViewController.createWith(storyboard: defaultStoryboard, url: url), sender: sender)
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
