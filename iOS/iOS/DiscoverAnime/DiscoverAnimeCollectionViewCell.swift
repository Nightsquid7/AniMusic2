//
//  DiscoverAnimeCollectionViewCell.swift
//  iOS
//
//  Created by Steven Berkowitz on R 2/04/07.
//  Copyright © Reiwa 2 nightsquid. All rights reserved.
//

import UIKit

class DiscoverAnimeCollectionViewCell: UICollectionViewCell {

    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 4
        return label
    }()

    func configureCell(anime: RealmAnimeSeries) {
        self.nameLabel.text = anime.name ?? "no name"

        contentView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        let nameLabelConstraints = [
          nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
          nameLabel.bottomAnchor.constraint(equalTo: contentView.topAnchor, constant: -20),
          nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
          nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
          nameLabel.heightAnchor.constraint(equalToConstant: 116),
          nameLabel.widthAnchor.constraint(equalToConstant: contentView.frame.width)
        ]

        NSLayoutConstraint.activate(nameLabelConstraints)
    }
}
