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
class BadgeView {
    var stackView = UIStackView()

}

