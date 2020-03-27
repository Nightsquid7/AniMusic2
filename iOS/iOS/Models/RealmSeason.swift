//
//  RealmSeasons.swift
//  abseil
//
//  Created by Steven Berkowitz on R 2/03/27.
//

import Foundation
import RealmSwift

class RealmSeason: Object, Codable {
    @objc dynamic var season: String
    @objc dynamic var year: String

    enum CodingKeys: String, CodingKey {
        case season = "Season"
        case year = "Year"
    }
}
