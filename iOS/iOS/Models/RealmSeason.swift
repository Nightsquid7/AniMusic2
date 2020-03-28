//
//  RealmSeasons.swift
//  abseil
//
//  Created by Steven Berkowitz on R 2/03/27.
//

import Foundation
import RealmSwift

class RealmSeason: Object, Codable {
    // MARK: - Properties
    @objc dynamic var season: String
    @objc dynamic var year: String
    @objc dynamic var selected: Bool = true

    enum CodingKeys: String, CodingKey {
        case season = "Season"
        case year = "Year"
    }
}
