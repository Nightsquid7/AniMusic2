//
//  AnimeSeries.swift
//  iOS
//
//  Created by Steven Berkowitz on R 2/03/20.
//  Copyright © Reiwa 2 nightsquid. All rights reserved.
//

import Foundation
import RealmSwift

protocol SearchResult {
    func sourceCount() -> Int
    func containsSpotify() -> Bool
    func containsAppleMusic() -> Bool
}

extension SearchResult {
    func sourceCount() -> Int {
        return [containsSpotify(), containsAppleMusic()].filter { $0 == true }.count
    }
}

class AnimeSeries: Object, Decodable {

    @objc dynamic var id: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var aniDbUri: String = ""
    @objc dynamic var format: String = ""
    @objc dynamic var season: String = ""
    @objc dynamic var year: String = ""
    @objc dynamic var titleImageName: String = ""
    var songs = List<AnimeSong>()
    @objc dynamic var bookmarked: Bool = false

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case aniDbUri = "AniDbUri"
        case format = "Format"
        case season = "Season"
        case year = "Year"
        case titleImageName = "TitleImageName"
    }

    enum AdditionalCodingKeys: String, CodingKey {
        case songsDict = "Songs"
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        aniDbUri = try values.decode(String.self, forKey: .aniDbUri)
        format = try values.decode(String.self, forKey: .format)
        season = try values.decode(String.self, forKey: .season)
        year = try values.decode(String.self, forKey: .year)
        titleImageName = try values.decode(String.self, forKey: .titleImageName)

        let nestedValues = try decoder.container(keyedBy: AdditionalCodingKeys.self)
        if let nestedSongs = try? nestedValues.decode([String: AnimeSong].self, forKey: .songsDict) {
            songs = List(array: nestedSongs.map { $0.value })
        }
    }

    required init() {}
}

extension AnimeSeries: SearchResult {
    func containsSpotify() -> Bool {
        return songs.contains(where: {$0.containsSpotify()})
    }
    func containsAppleMusic() -> Bool {
        return songs.contains(where: {$0.containsAppleMusic()})
    }
}

class AnimeSong: Object, Decodable {

    @objc dynamic var id: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var nameEnglish: String = ""
    @objc dynamic var classification: String = ""
    @objc dynamic var relation: String = ""
    var artists = List<Artist>()
    var ranges = List<EpisodeRange>()
    var sources = List<SongSearchResult>()

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case nameEnglish = "NameEn"
        case classification = "Classification"
        case relation = "Relation"
        case artists = "Artists"
    }

    enum NestedCodingKeys: String, CodingKey {
        case sources = "Sources"
        case ranges = "Ranges"
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        nameEnglish = try values.decode(String.self, forKey: .nameEnglish)
        classification = try values.decode(String.self, forKey: .classification)
        relation = try values.decode(String.self, forKey: .relation)

        artists = try values.decode(List<Artist>.self, forKey: .artists)
        let nestedValues = try decoder.container(keyedBy: NestedCodingKeys.self)
        if let nestedRanges = try? nestedValues.decode([EpisodeRange].self, forKey: .ranges) {
            ranges = List(array: nestedRanges.map { $0 })
        }

        if let nestedSources = try? nestedValues.decode([String: SongSearchResult].self, forKey: .sources) {
            sources = List(array: nestedSources.map { $0.value })
        }
    }

    required init() {}

    // calculate the value for sorting based on relation and first ranges
    // TODO: Implement Animes.value() with non-optional values
    func value() -> Int {
        return 7
    }
}

extension AnimeSong: SearchResult {
    func containsSpotify() -> Bool {
        return sources.filter { $0.type == "Spotify" }.count > 0
    }
    func containsAppleMusic() -> Bool {
        return sources.filter { $0.type == "AppleMusic"}.count > 0
    }
}

enum Relation: String {
    case opening
    case insertSong = "insert song"
    case imageSong = "image song"
    case ending

    var value: Int {
        switch self {
        case .opening: return 0
        case .insertSong, .imageSong: return 1
        case .ending: return 2
        }
    }
}

extension AnimeSong: Comparable {
    static func < (lhs: AnimeSong, rhs: AnimeSong) -> Bool {
        return lhs.value() < rhs.value()
    }

}

class EpisodeRange: Object, Decodable {
    var start: Int = 0
    var end: Int = 0

    enum CodingKeys: String, CodingKey {
        case start = "Start"
        case end = "End"
    }
}

class SongSearchResult: Object, Decodable {
    @objc dynamic var relation: String = ""
    @objc dynamic var songId: String = ""
    @objc dynamic var URI: String = "" // link to spotify/apple music
    @objc dynamic var name: String = ""
    @objc dynamic var externalUrl: String = ""
    @objc dynamic var type: String = ""

    enum CodingKeys: String, CodingKey {
        case relation = "Relation"
        case songId = "SongId"
        case URI
        case name = "Name"
        case externalUrl = "ExternalUrl"
        case type = "Source"
    }

    func containSpotify() -> Bool {
        return type == "Spotify"
    }
    func containsAppleMusic() -> Bool {
        return  type == "Apple Music"
    }
}

enum SourceType: String, CaseIterable {
    case appleMusic = "AppleMusic"
    case spotify = "Spotify"
    case youTube = "Youtube"
    case googleMusic = "GoogleMusic"
}

extension SourceType {
    static func allCasesToString() -> [String] {
        return SourceType.allCases.map { $0.rawValue }
    }
}

extension SourceType: Comparable {
    static func < (lhs: SourceType, rhs: SourceType) -> Bool {
        return lhs.value() < rhs.value()
    }
    
    func value() -> Int {
        switch self {
        case .appleMusic:
            return 1
        case .spotify:
            return 2
        case .youTube:
            return 3
        case .googleMusic:
            return 4
        }
    }
}
class Artist: Object, Decodable {
    @objc dynamic var id: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var nameEnglish: String = ""

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case nameEnglish = "NameEn"
    }
}
