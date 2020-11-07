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

    func configureCell(from song: AnimeSong) {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameEnglishLabel.translatesAutoresizingMaskIntoConstraints = false
        artistLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(nameLabel)
        contentView.addSubview(nameEnglishLabel)
        contentView.addSubview(artistLabel)

        nameLabel.text =  song.name
        nameEnglishLabel.text = song.nameEnglish
        artistLabel.text = song.artists[0].name

        if song.sourceCount() > 0 {
            accessoryView = UIImageView(image: UIImage(systemName: "music.note"))
        }

        // MARK: TODO - rename constraint constants
        let toTopNeighbor: CGFloat = 20
        let toBottomNeighbor: CGFloat = 20
        let toLeadingNeighbor: CGFloat = 20
        let toTrailingNeighbor: CGFloat = -20

        let nameLabelConstraints = [
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: toTopNeighbor),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: toLeadingNeighbor),
        ]

        let nameEnglishLabelConstraints = [
            nameEnglishLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: toBottomNeighbor),
            nameEnglishLabel.bottomAnchor.constraint(equalTo: artistLabel.topAnchor, constant: -toTopNeighbor),
            nameEnglishLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: toLeadingNeighbor),
            nameEnglishLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: toTrailingNeighbor)
        ]

        let artistLabelConstraints = [
            artistLabel.topAnchor.constraint(equalTo: nameEnglishLabel.bottomAnchor, constant: toBottomNeighbor),
            artistLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -toBottomNeighbor),
            artistLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: toLeadingNeighbor),
            artistLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: toTrailingNeighbor)
        ]

        NSLayoutConstraint.activate(nameLabelConstraints)
        NSLayoutConstraint.activate(nameEnglishLabelConstraints)
        NSLayoutConstraint.activate(artistLabelConstraints)
    }

    override func prepareForReuse() {
        nameLabel.text = ""
        nameEnglishLabel.text = ""
    }
}
