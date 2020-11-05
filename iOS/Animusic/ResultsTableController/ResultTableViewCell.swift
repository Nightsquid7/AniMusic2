import UIKit

class ResultTableViewCell: UITableViewCell {

    lazy var animeImage: UIImageView = {
      let imageView = UIImageView()
      return imageView
    }()

    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    lazy var seasonLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    func configureCell(from searchResult: SearchResult) {
        selectionStyle = .none
        animeImage.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        seasonLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(animeImage)
        contentView.addSubview(nameLabel)
        contentView.addSubview(seasonLabel)

        if let anime = searchResult as? RealmAnimeSeries {
            configureCell(from: anime)
        } else if let song = searchResult as? RealmAnimeSong {
            configureCell(from: song)
        }

        setConstraints()
    }

    fileprivate func configureCell(from anime: RealmAnimeSeries) {
        animeImage.setImage(for: anime)
        nameLabel.text = anime.name
        seasonLabel.text = anime.season + " " + anime.year
    }

    fileprivate func configureCell(from song: RealmAnimeSong) {
        animeImage.image = UIImage(systemName: "music.note")
        nameLabel.text = song.nameEnglish
        seasonLabel.text = song.artists.first?.name
    }

    let downOffset: CGFloat = 20
    let upVertical: CGFloat = -20
    let horizontalOffset: CGFloat = 10
    let imageHeight: CGFloat = 150
    let imageWidth: CGFloat = 112

    func setConstraints() {
        let animeImageConstraints = [
            animeImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: downOffset),
            animeImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalOffset),
            animeImage.heightAnchor.constraint(equalToConstant: imageHeight),
            animeImage.widthAnchor.constraint(equalToConstant: imageWidth),
        ]

        let seasonLabelConstraints = [
            seasonLabel.bottomAnchor.constraint(equalTo: animeImage.bottomAnchor),
            seasonLabel.leadingAnchor.constraint(equalTo: animeImage.trailingAnchor, constant: horizontalOffset),
        ]

        let nameLabelConstraints = [
            nameLabel.bottomAnchor.constraint(equalTo: seasonLabel.topAnchor, constant: upVertical),
            nameLabel.leadingAnchor.constraint(equalTo: animeImage.trailingAnchor, constant: horizontalOffset),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: horizontalOffset)

        ]

        NSLayoutConstraint.activate(animeImageConstraints)
        NSLayoutConstraint.activate(seasonLabelConstraints)
        NSLayoutConstraint.activate(nameLabelConstraints)
    }

    override func prepareForReuse() {
        animeImage.image = UIImage()
        nameLabel.text = ""
        seasonLabel.text = ""
    }

}
