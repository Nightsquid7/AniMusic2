//
//  SongPlayerViewController.swift
//  iOS
//
//  Created by Steven Berkowitz on R 2/04/03.
//  Copyright © Reiwa 2 nightsquid. All rights reserved.
//

import UIKit
import Then

class SongPlayerViewController: UIViewController {

    // MARK: - IBOutlets
    @IBAction func playButton(_ sender: UIButton) {
        guard let url = URL(string: viewModel.source.externalUrl!)
            else {
                print("could not get url from \(String(describing: viewModel.source.externalUrl))")
                return
        }
        UIApplication.shared.open(url, options: [:]) { success in
            print("opened url: \(success)")
        }
    }

    // MARK: - Properties
    var viewModel: SongPlayerViewModel!

    // MARK: - Initialization
    static func createWith(storyboard: UIStoryboard, viewModel: SongPlayerViewModel) -> SongPlayerViewController {
        return (storyboard.instantiateViewController(withIdentifier: "SongPlayerViewController") as! SongPlayerViewController).then { vc in
            vc.viewModel = viewModel
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

    }

}
