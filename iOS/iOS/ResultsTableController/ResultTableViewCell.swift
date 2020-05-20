//
//  ResultTableViewCell.swift
//  abseil
//
//  Created by Steven Berkowitz on 2020/05/13.
//

import UIKit

class ResultTableViewCell: UITableViewCell {

    lazy var animeImage: UIImageView = {
      let imageView = UIImageView()
      // set placeholder image here
      imageView.image = UIImage(named: "No Guns Life")
      return imageView
    }()

    lazy var animeNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        return label
    }()

    lazy var animeSeasonLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    func configureCell(from anime: RealmAnimeSeries) {
        animeImage.setImage(for: anime)
        animeImage.translatesAutoresizingMaskIntoConstraints = false
        animeNameLabel.translatesAutoresizingMaskIntoConstraints = false
        animeSeasonLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(animeImage)
        contentView.addSubview(animeNameLabel)
        contentView.addSubview(animeSeasonLabel)

        animeNameLabel.text = anime.name
        animeSeasonLabel.text = (anime.season ?? "") + " " + (anime.year ?? "")

        let animeImageConstraints = [
            animeImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            animeImage.heightAnchor.constraint(equalToConstant: 150),
            animeImage.widthAnchor.constraint(equalToConstant: 112),
            animeImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        ]

        // Position the labels next to the image,

        let animeNameLabelConstraints = [
            animeNameLabel.bottomAnchor.constraint(equalTo: animeSeasonLabel.topAnchor, constant: -20),
            animeNameLabel.leadingAnchor.constraint(equalTo: animeImage.trailingAnchor, constant: 10),
            animeNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5)
        ]

        let animeSeasonLabelConstraints = [
            animeSeasonLabel.bottomAnchor.constraint(equalTo: animeImage.bottomAnchor),
            animeSeasonLabel.leadingAnchor.constraint(equalTo: animeImage.trailingAnchor, constant: 10)
        ]

        NSLayoutConstraint.activate(animeImageConstraints)
        NSLayoutConstraint.activate(animeNameLabelConstraints)
        NSLayoutConstraint.activate(animeSeasonLabelConstraints)
    }

    override func prepareForReuse() {

    }

}
