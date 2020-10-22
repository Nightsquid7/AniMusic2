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
        let imageName = anime.titleImageName
        let url = URL(string: "https://animusic2-70683.firebaseapp.com/\(imageName)")
        self.kf.setImage(with: url, options: [])
    }
}

// MARK: UIStackView
// get stack view containing badges for every music source in either song or anime
// from anime -> Get all sources from all songs
// If source contains spotify, add a badge
extension UIStackView {
    func configureBadgeView(from searchResult: SearchResult) {
        let sources: [RealmSongSearchResult]!
        if let anime = searchResult as? RealmAnimeSeries {
            sources = Array(anime.songs).flatMap { $0.sources }
        } else if let song = searchResult as? RealmAnimeSong {
            sources = Array(song.sources)
        } else { return }

        guard sources.count > 0 else {
            removeAllArrangedSubviews()
            return }

        self.axis = .horizontal
        self.distribution = .equalSpacing
        self.addBadges(from: sources)
        return
    }

    private func addBadges(from sources: [RealmSongSearchResult]) {
        let containsSpotify = sources.filter { $0.type == "Spotify" }.count > 0
        if containsSpotify {
            let spotifyBadge = UIImageView(image: UIImage(named: "Spotify_Icon_RGB_Green"))
            spotifyBadge.contentMode = .scaleAspectFit
            self.addArrangedSubview(spotifyBadge)
        }

        return
    }

    func removeAllArrangedSubviews() {
        for subview in self.arrangedSubviews {
            subview.removeFromSuperview()
        }
    }
}
