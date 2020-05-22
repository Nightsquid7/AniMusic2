//
//  UIKitExtensions.swift
//  RxDataSources
//
//  Created by Segii Shulga on 4/26/16.
//  Copyright © 2016 kzaher. All rights reserved.
//

import class UIKit.UITableViewCell
import class UIKit.UITableView
import struct Foundation.IndexPath
import Kingfisher

protocol ReusableView: class {
    static var reuseIdentifier: String { get }
}

extension ReusableView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableViewCell: ReusableView {
}

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>(forIndexPath indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }

        return cell
    }
}

// MARK: UIImage
extension UIImageView {
    func setImage(for anime: RealmAnimeSeries) {
        guard let imageName = anime.titleImageName else { return }

        let url = URL(string: "https://animusic2-70683.firebaseapp.com/\(imageName)")
        self.kf.setImage(with: url) { result in
            switch (result) {
            case .success(let value):
                print(value.originalSource)
            case .failure(let err):
                print(err)
            }

        }

    }
}

// MARK: UIStackView
// get stack view containing badges for every music source in either song or anime
// from anime -> Get all sources from all songs
// from song  -> Get all sources from specific song
// If source contains spotify, add a badge
extension UIStackView {
    func makeAnimeSeriesBadgeView(from anime: RealmAnimeSeries? = nil, from song: RealmAnimeSong? = nil) {
        var sources: [RealmSongSearchResult]
        if let anime = anime {
            sources = Array(anime.songs).flatMap { $0.sources }
        } else if let song = song {
            sources = song.sources.map { $0 }
        } else { return }

        guard sources.count > 0 else { return }

        self.addArrangedSubview(UIView())
        self.axis = .horizontal
        self.distribution = .equalSpacing
        self.contentMode = .left

        let containsSpotify = sources.filter { $0.source == "Spotify"}.count > 0
        if containsSpotify {
            let spotifyBadge = UIImageView(image: UIImage(named: "Spotify_Icon_RGB_Green"))
            spotifyBadge.contentMode = .scaleAspectFit
            self.addArrangedSubview(spotifyBadge)
        }

        return
    }
}
