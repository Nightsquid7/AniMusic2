//
//  AnimeSongTableViewCell.swift
//  iOS
//
//  Created by Steven Berkowitz on R 2/03/29.
//  Copyright © Reiwa 2 nightsquid. All rights reserved.
//

import UIKit

class AnimeSongTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameEnglishLabel: UILabel!
    @IBOutlet weak var relationLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!

    func configureCell(name: String,
                       nameEnglish: String,
                       relation: String, song: RealmAnimeSong) {
        nameLabel.text =  name
        nameEnglishLabel.text = nameEnglish
        relationLabel.text = relation
        if let ranges = song.ranges.first {
            startLabel.text = String(ranges.start.value!)
            endLabel.text = String(ranges.end.value!)
        }

    }

    override func prepareForReuse() {
        nameLabel.text = ""
        nameEnglishLabel.text = ""
        relationLabel.text = ""
        startLabel.text = ""
        endLabel.text = ""
    }
}
