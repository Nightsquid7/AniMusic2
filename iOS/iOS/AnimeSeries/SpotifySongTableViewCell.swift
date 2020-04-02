//
//  SpotifySongTableViewCell.swift
//  iOS
//
//  Created by Steven Berkowitz on R 2/04/02.
//  Copyright © Reiwa 2 nightsquid. All rights reserved.
//

import UIKit

class SpotifySongTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameEnglishLabel: UILabel!
    @IBOutlet weak var spotifyImageView: UIImageView!

    func configure(name: String, nameEnglish: String) {
        nameLabel.text = name
        nameEnglishLabel.text = nameEnglish
        spotifyImageView.image = UIImage(named: "Spotify_Icon_RGB_Green")
    }
}
