//
//  DiscoverAnimeCollectionViewCell.swift
//  iOS
//
//  Created by Steven Berkowitz on R 2/04/07.
//  Copyright © Reiwa 2 nightsquid. All rights reserved.
//

import UIKit
import Kingfisher

class DiscoverAnimeCollectionViewCell: UICollectionViewCell {

    lazy var image: UIImageView = {
        let image = UIImageView()
        // set placeholder image here
        image.image = UIImage(named: "No Guns Life")
        return image
    }()

    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 4
        return label
    }()

    let musicSourcesBadgeView = UIStackView()

    // host url
    // https://animusic2-70683.firebaseapp.com/

    func configureCell(anime: RealmAnimeSeries) {
        self.nameLabel.text = anime.name ?? "no name"
        image.setImage(for: anime)
        musicSourcesBadgeView.configureBadgeView(from: anime)

        contentView.addSubview(image)
        contentView.addSubview(nameLabel)
        contentView.addSubview(musicSourcesBadgeView)

        image.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        musicSourcesBadgeView.translatesAutoresizingMaskIntoConstraints = false

        let imageConstraints = [
            image.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            image.bottomAnchor.constraint(equalTo: nameLabel.topAnchor),
            image.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            image.widthAnchor.constraint(equalToConstant: 112),
            image.heightAnchor.constraint(equalToConstant: 150)
        ]

        let nameLabelConstraints = [
            nameLabel.topAnchor.constraint(equalTo: image.bottomAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.heightAnchor.constraint(equalToConstant: 50),
            nameLabel.widthAnchor.constraint(equalToConstant: contentView.frame.width)
        ]

        let musicSourcesBadgeViewConstraints = [
            musicSourcesBadgeView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            musicSourcesBadgeView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            musicSourcesBadgeView.heightAnchor.constraint(equalToConstant: 30),
            musicSourcesBadgeView.widthAnchor.constraint(equalToConstant: 30)
        ]

        NSLayoutConstraint.activate(nameLabelConstraints)
        NSLayoutConstraint.activate(imageConstraints)
        NSLayoutConstraint.activate(musicSourcesBadgeViewConstraints)
    }

    override func prepareForReuse() {
        print("\nprepare for reuse -> \(nameLabel.text)")
        self.nameLabel.text = ""
        musicSourcesBadgeView.removeAllArrangedSubviews()
    }
}
