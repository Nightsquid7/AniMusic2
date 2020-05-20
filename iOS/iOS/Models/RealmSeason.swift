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
    @objc dynamic var season: String = ""
    @objc dynamic var year: String = ""
    @objc dynamic var selected: Bool = true

    enum CodingKeys: String, CodingKey {
        case season = "Season"
        case year = "Year"
    }

    // MARK: - temporary?
    // Will this convenience initializer interfere with Codable protocol?
    convenience init(season: String, year: String) {
        self.init()
        self.season = season
        self.year = year
    }
}

extension RealmSeason {
    func getTitleString() -> String {
        return self.season + " " + self.year
    }
}
