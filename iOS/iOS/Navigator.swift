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
        case AnimeListViewController
        case AnimeSeriesViewController
        case AnimeSongViewController
        case SongPlayerViewController
    }

    func show(segue: Segue, sender: UIViewController) {
        switch segue {
        case .AnimeListViewController:
            show(target: AnimeListViewController.createWith(storyboard: defaultStoryboard), sender: sender)
            print()
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
            sender.present(target, animated: true, completion: nil)
        }
    }
}
