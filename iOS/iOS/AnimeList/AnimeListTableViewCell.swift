//
//  AnimeListTableViewCell.swift
//  iOS
//
//  Created by Steven Berkowitz on R 2/03/24.
//  Copyright © Reiwa 2 nightsquid. All rights reserved.
//

import UIKit

class AnimeListTableViewCell: UITableViewCell {

    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 4

        return label
    }()

    // MARK: - todo build proper formatBadge
    lazy var formatBadge: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()

    lazy var  spotifyBadge: UIImageView = {
        let view = UIImageView(frame: CGRect())

        return view
    }()

    override func awakeFromNib() {
        super.awakeFromNib()

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        formatBadge.translatesAutoresizingMaskIntoConstraints = false
        spotifyBadge.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(nameLabel)
        contentView.addSubview(formatBadge)
        contentView.addSubview(spotifyBadge)

        let nameLabelConstraints = [
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameLabel.widthAnchor.constraint(equalToConstant: 250)
        ]

        let formatBadgeConstraints = [
            formatBadge.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            formatBadge.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ]

        let spotifyBadgeConstraints = [
            spotifyBadge.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            spotifyBadge.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            spotifyBadge.heightAnchor.constraint(equalToConstant: 35),
            spotifyBadge.widthAnchor.constraint(equalToConstant: 35)
        ]

        NSLayoutConstraint.activate(nameLabelConstraints)
        NSLayoutConstraint.activate(formatBadgeConstraints)
        NSLayoutConstraint.activate(spotifyBadgeConstraints)
    }

    func configureCell(name: String, format: String, appleMusic: Bool, spotify: Bool) {
        nameLabel.text = name
        formatBadge.text = format
        if spotify {
            spotifyBadge.image = UIImage(named: "Spotify_Icon_RGB_Green")
        }
    }

    override func prepareForReuse() {
        nameLabel.text = ""
        formatBadge.text = ""
        spotifyBadge.image = nil
    }
}
