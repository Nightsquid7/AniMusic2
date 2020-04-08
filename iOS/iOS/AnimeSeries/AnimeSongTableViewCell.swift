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

    func configureCell(name: String, nameEnglish: String) {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameEnglishLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)
        contentView.addSubview(nameEnglishLabel)

        nameLabel.text =  name
        nameEnglishLabel.text = nameEnglish

        let nameLabelConstraints = [
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            nameLabel.bottomAnchor.constraint(equalTo: nameEnglishLabel.topAnchor, constant: -10),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ]

        let nameEnglishLabelConstraints = [
            nameEnglishLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            nameEnglishLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            nameEnglishLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameEnglishLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ]

        NSLayoutConstraint.activate(nameLabelConstraints)
        NSLayoutConstraint.activate(nameEnglishLabelConstraints)
    }

    override func prepareForReuse() {
        nameLabel.text = ""
        nameEnglishLabel.text = ""

    }
}
