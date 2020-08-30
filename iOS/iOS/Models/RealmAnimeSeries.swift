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
    let songs = List<RealmAnimeSong>()

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
        if let songs = anime.songs {
            for song in songs {
                self.songs.append(RealmAnimeSong(from: song.value))
            }
        }
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
    // want to add boolean -> hasSources

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
        guard let start1 = lhs.ranges.first?.start.value,
            let start2 = rhs.ranges.first?.start.value,
            start1 != start2 else {
            // There are no ranges to compare, or start ranges are equal
            // compare Relations
                if let relation1 = Relation(rawValue: lhs.relation!)?.value, let relation2 = Relation(rawValue: rhs.relation!)?.value {
                    return relation1 < relation2
                }
            return false
        }
        return start1 < start2
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
