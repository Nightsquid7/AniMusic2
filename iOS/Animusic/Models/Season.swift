//
//  RealmSeasons.swift
//  abseil
//
//  Created by Steven Berkowitz on R 2/03/27.
//

import Foundation
import RealmSwift

class Season: Object, Codable {
    // MARK: - Properties
    @objc dynamic var season: String = ""
    @objc dynamic var year: String = ""
    @objc dynamic var count: String = ""
    @objc dynamic var timeUpdated = TimeInterval()

    enum CodingKeys: String, CodingKey {
        case season = "Season"
        case year = "Year"
        case count = "Count"

    }

}

extension Season {
    func titleString() -> String {
        return season + " " + year
    }

    func databaseId() -> String {
        return season + "-" + year
    }
}
