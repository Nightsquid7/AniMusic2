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

    func configureCell(from anime: RealmAnimeSeries) {
        animeImage.setImage(for: anime)
        animeImage.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(animeImage)

        let animeImageConstraints = [
            animeImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            animeImage.heightAnchor.constraint(equalToConstant: 194),
            animeImage.widthAnchor.constraint(equalToConstant: 113),
            animeImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        ]

        NSLayoutConstraint.activate(animeImageConstraints)
    }

    override func prepareForReuse() {

    }

}
