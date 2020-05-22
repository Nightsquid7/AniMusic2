//
//  AnimeSongTableViewCell.swift
//  iOS
//
//  Created by Steven Berkowitz on R 2/03/29.
//  Copyright © Reiwa 2 nightsquid. All rights reserved.
//

import UIKit

class AnimeSongTableViewCell: UITableViewCell {

    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        return label
    }()

    lazy var nameEnglishLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        return label
    }()

    lazy var artistLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    var musicSourcesBadgeView = UIStackView()

    func configureCell(from song: RealmAnimeSong) {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameEnglishLabel.translatesAutoresizingMaskIntoConstraints = false
        artistLabel.translatesAutoresizingMaskIntoConstraints = false

        musicSourcesBadgeView.configureBadgeView(from: song)
        musicSourcesBadgeView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(nameLabel)
        contentView.addSubview(nameEnglishLabel)
        contentView.addSubview(artistLabel)
        contentView.addSubview(musicSourcesBadgeView)

        nameLabel.text =  song.name ?? "Oh-No name?"
        nameEnglishLabel.text = song.nameEnglish ?? ""
        // MARK: - todo Display multiple names
        artistLabel.text = song.artists[0].name

        let nameLabelConstraints = [
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            nameLabel.bottomAnchor.constraint(equalTo: nameEnglishLabel.topAnchor, constant: -10),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: musicSourcesBadgeView.leadingAnchor, constant: -5)
        ]

        let musicSourcesBadgeViewConstraints = [
            musicSourcesBadgeView.topAnchor.constraint(equalTo: nameLabel.topAnchor),
            musicSourcesBadgeView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -7),
            musicSourcesBadgeView.heightAnchor.constraint(equalToConstant: 30),
            musicSourcesBadgeView.widthAnchor.constraint(equalToConstant: 30)
        ]

        let nameEnglishLabelConstraints = [
            nameEnglishLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            nameEnglishLabel.bottomAnchor.constraint(equalTo: artistLabel.topAnchor, constant: -10),
            nameEnglishLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameEnglishLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ]

        let artistLabelConstraints = [
            artistLabel.topAnchor.constraint(equalTo: nameEnglishLabel.bottomAnchor, constant: 10),
            artistLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            artistLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            artistLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ]

        NSLayoutConstraint.activate(nameLabelConstraints)
        NSLayoutConstraint.activate(musicSourcesBadgeViewConstraints)
        NSLayoutConstraint.activate(nameEnglishLabelConstraints)
        NSLayoutConstraint.activate(artistLabelConstraints)
    }

    override func prepareForReuse() {
        nameLabel.text = ""
        nameEnglishLabel.text = ""

    }
}
