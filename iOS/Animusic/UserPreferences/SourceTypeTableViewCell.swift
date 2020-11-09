//
//  SourceTypeTableViewCell.swift
//  Pods
//
//  Created by Steven Berkowitz on 2020/11/09.
//

import UIKit

class SourceTypeTableViewCell: UITableViewCell {
    var sourceType: SourceType!

    func configureFor(_ sourceType: SourceType) {
        self.sourceType = sourceType
        textLabel?.text = sourceType.rawValue
        accessoryType = .checkmark
    }

}
