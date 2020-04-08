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

    lazy var image: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "No Guns Life")
        return image
    }()

    func configureCell(anime: RealmAnimeSeries) {
        self.nameLabel.text = anime.name ?? "no name"

        contentView.addSubview(nameLabel)
        contentView.addSubview(image)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        image.translatesAutoresizingMaskIntoConstraints = false

        let nameLabelConstraints = [
            nameLabel.topAnchor.constraint(equalTo: image.bottomAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.heightAnchor.constraint(equalToConstant: 50),
            nameLabel.widthAnchor.constraint(equalToConstant: contentView.frame.width)
        ]

        let imageConstraints = [
            image.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            image.bottomAnchor.constraint(equalTo: nameLabel.topAnchor),
            image.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            image.widthAnchor.constraint(equalToConstant: 112),
            image.heightAnchor.constraint(equalToConstant: 149)
        ]

        NSLayoutConstraint.activate(nameLabelConstraints)
        NSLayoutConstraint.activate(imageConstraints)
    }
}
