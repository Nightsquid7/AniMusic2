//
//  SpotifySongTableViewCell.swift
//  iOS
//
//  Created by Steven Berkowitz on R 2/04/02.
//  Copyright © Reiwa 2 nightsquid. All rights reserved.
//

import UIKit

class SpotifySongTableViewCell: UITableViewCell {

    lazy var spotifyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Spotify_Icon_RGB_Green")
        return imageView
    }()

    func configureCell() {

        contentView.addSubview(spotifyImageView)
        spotifyImageView.translatesAutoresizingMaskIntoConstraints = false

        let constraints = [
            spotifyImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            spotifyImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            spotifyImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            spotifyImageView.heightAnchor.constraint(equalToConstant: 35),
            spotifyImageView.widthAnchor.constraint(equalToConstant: 35)

        ]
        NSLayoutConstraint.activate(constraints)
    }

}
