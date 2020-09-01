//
//  AnimeSeries.swift
//  iOS
//
//  Created by Steven Berkowitz on R 2/03/20.
//  Copyright © Reiwa 2 nightsquid. All rights reserved.
//

import Foundation
import RealmSwift

class RealmAnimeSeries: Object {

    @objc dynamic var id: String?
    @objc dynamic var name: String?
    @objc dynamic var aniDbUri: String?
    @objc dynamic var format: String?
    @objc dynamic var season: String?
    @objc dynamic var year: String?
    @objc dynamic var titleImageName: String?
    var songs = List<RealmAnimeSong>()

    convenience init(from anime: AnimeSeries) {
        self.init()
        self.id = anime.id
        self.name = anime.name
        self.aniDbUri = anime.aniDbUri
        self.format = anime.format
        self.season = anime.season
        self.year = anime.year
        self.titleImageName = anime.titleImageName
        // add songs if they exist
        for song in anime.songs {
            self.songs.append(RealmAnimeSong(from: song.value))
        }
        self.songs.sort()

    }

}

class RealmAnimeSong: Object {
    @objc dynamic var id: String?
    @objc dynamic var name: String?
    @objc dynamic var nameEnglish: String?
    @objc dynamic var classification: String?
    @objc dynamic var relation: String?
    let ranges = List<RealmEpisodeRange>()
    let artists = List<RealmArtist>()
    let sources = List<RealmSongSearchResult>()

    convenience init(from song: AnimeSong) {
        self.init()
        self.id = song.id
        self.name = song.name
        self.nameEnglish = song.nameEnglish
        self.classification = song.classification
        self.relation = song.relation
        // add ranges if they exist
        if let ranges = song.ranges {
            for range in ranges {
                self.ranges.append(RealmEpisodeRange(value: ["start": range["Start"], "end": range["End"]]))
            }
        }

        if let artists = song.artists {
        // add artists
            for artist in artists {
                self.artists.append(RealmArtist(from: artist))
            }
        }
        // add sources if they exist
        if let sources = song.sources {
            for source in sources {
                self.sources.append(RealmSongSearchResult(from: source.value))
            }
        }
    }

    // calculate the value for sorting based on relation and first ranges
    func value() -> Int {

        guard let firstRangeValue = ranges.first?.start.value, let relationValue = Relation(rawValue: relation!)?.value else {
            // only have start range
            if let firstRangeValue = ranges.first?.start.value {
                return firstRangeValue
            }
            // only have relation, opening, ending etc
            if let relationValue = Relation(rawValue: relation!)?.value {
                return relationValue
            }
            // have nothing, return arbitrary value
            return 7
        }

        return firstRangeValue + relationValue
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

extension RealmAnimeSong: Comparable {
    static func < (lhs: RealmAnimeSong, rhs: RealmAnimeSong) -> Bool {
        return lhs.value() < rhs.value()
    }

}

class RealmEpisodeRange: Object {
    let start = RealmOptional<Int>()
    let end = RealmOptional<Int>()
}

class RealmSongSearchResult: Object {
    @objc dynamic var relation: String?
    @objc dynamic var songId: String?
    @objc dynamic var URI: String? // link to spotify/apple music
    @objc dynamic var name: String?
    @objc dynamic var externalUrl: String?
    @objc dynamic var source: String?

    convenience init(from searchResult: SongSearchResult) {
        self.init()
        self.relation = searchResult.relation
        self.songId = searchResult.songId
        self.URI = searchResult.URI
        self.name = searchResult.name
        self.externalUrl = searchResult.externalUrl
        self.source = searchResult.source
    }
}

class RealmArtist: Object {
    @objc dynamic var id: String?
    @objc dynamic var name: String?
    @objc dynamic var nameEnglish: String?

    convenience init(from artist: Artist) {
        self.init()
        self.id = artist.id
        self.name = artist.name
        self.nameEnglish = artist.nameEnglish
    }
}
