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

    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 4
        return label
    }()

    lazy var image: UIImageView = {
        let image = UIImageView()
        // set placeholder image here
        image.image = UIImage(named: "No Guns Life")
        return image
    }()

    // host url
    // https://animusic2-70683.firebaseapp.com/
    
    func configureCell(anime: RealmAnimeSeries) {
        self.nameLabel.text = anime.name ?? "no name"
        if let imageName = anime.titleImageName {
            let url = URL(string: "https://animusic2-70683.firebaseapp.com/\(imageName)")
            image.kf.setImage(with: url) { result in
                switch (result) {
                case .success(let value):
                    print(value.originalSource)
                case .failure(let err):
                    print(err)
                }

                print(imageName)
            }
        }
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
