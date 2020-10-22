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
      return imageView
    }()

    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        return label
    }()

    lazy var seasonLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    var musicSourcesBadgeView = UIStackView()

    func configureCell(from searchResult: SearchResult) {
        animeImage.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        seasonLabel.translatesAutoresizingMaskIntoConstraints = false
        musicSourcesBadgeView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(animeImage)
        contentView.addSubview(nameLabel)
        contentView.addSubview(seasonLabel)
        contentView.addSubview(musicSourcesBadgeView)

        musicSourcesBadgeView.configureBadgeView(from: searchResult)

        if let anime = searchResult as? RealmAnimeSeries {
            configureCell(from: anime)
        } else if let song = searchResult as? RealmAnimeSong {
            configureCell(from: song)
        }

        setConstraints()
    }

    func configureCell(from anime: RealmAnimeSeries) {
        animeImage.setImage(for: anime)
        nameLabel.text = anime.name
        seasonLabel.text = anime.season + " " + anime.year
    }

    func configureCell(from song: RealmAnimeSong) {
        animeImage.image = UIImage(systemName: "music.note")
        nameLabel.text = song.nameEnglish
        seasonLabel.text = song.artists.first?.name ?? ""
    }

    func setConstraints() {
        let animeImageConstraints = [
            animeImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            animeImage.heightAnchor.constraint(equalToConstant: 150),
            animeImage.widthAnchor.constraint(equalToConstant: 112),
            animeImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        ]

        // Position the labels next to the animeImage,
        let nameLabelConstraints = [
            nameLabel.bottomAnchor.constraint(equalTo: seasonLabel.topAnchor, constant: -20),
            nameLabel.leadingAnchor.constraint(equalTo: animeImage.trailingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5)
        ]

        let seasonLabelConstraints = [
            seasonLabel.bottomAnchor.constraint(equalTo: musicSourcesBadgeView.topAnchor, constant: -20),
            seasonLabel.leadingAnchor.constraint(equalTo: animeImage.trailingAnchor, constant: 10)
        ]

        let musicSourcesBadgeViewConstraints = [
            musicSourcesBadgeView.bottomAnchor.constraint(equalTo: animeImage.bottomAnchor),
            musicSourcesBadgeView.leadingAnchor.constraint(equalTo: animeImage.trailingAnchor, constant: 10),
            musicSourcesBadgeView.heightAnchor.constraint(equalToConstant: 30),
            musicSourcesBadgeView.widthAnchor.constraint(equalToConstant: 30)
        ]

        NSLayoutConstraint.activate(animeImageConstraints)
        NSLayoutConstraint.activate(nameLabelConstraints)
        NSLayoutConstraint.activate(seasonLabelConstraints)
        NSLayoutConstraint.activate(musicSourcesBadgeViewConstraints)
    }

    override func prepareForReuse() {
        animeImage.image = UIImage()
        nameLabel.text = ""
        seasonLabel.text = ""
        musicSourcesBadgeView.removeAllArrangedSubviews()
    }

}
