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