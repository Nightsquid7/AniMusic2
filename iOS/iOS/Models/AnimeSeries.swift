//
//  AnimeSeries.swift
//  iOS
//
//  Created by Steven Berkowitz on R 2/03/20.
//  Copyright © Reiwa 2 nightsquid. All rights reserved.
//

import Foundation

struct AnimeSeries: Codable {

    let id: String
    let name: String
    let aniDbUri: String
    let format: String
    let season: String
    let year: String
    let songs: [String: AnimeSong]?
    let titleImageName: String

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case aniDbUri = "AniDbUri"
        case format = "Format"
        case season = "Season"
        case year = "Year"
        case songs = "Songs"
        case titleImageName = "TitleImageName"
    }

}

struct AnimeSong: Codable {
    let id: String
    let name: String
    let nameEnglish: String
    let ranges: [[String: Int]]?
    let classification: String
    let artists: [Artist]?
    let relation: String
    let sources: [String: SongSearchResult]?

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case nameEnglish = "NameEn"
        case ranges = "Ranges"
        case classification = "Classification"
        case artists = "Artists"
        case relation = "Relation"
        case sources = "Sources"
    }
}

struct EpisodeRange: Codable {
    let start: Int?
    let end: Int?
}

//enum SourceType: String, Codable {
//    case Spotify
//    case AppleMusic
//}

struct SongSearchResult: Codable {
    let relation: String
    let songId: String
    let URI: String // link to spotify/apple music
    let name: String
    let externalUrl: String
    let source: String

    enum CodingKeys: String, CodingKey {
        case relation = "Relation"
        case songId = "SongId"
        case URI
        case name = "Name"
        case externalUrl = "ExternalUrl"
        case source = "Source"
    }
}

struct Artist: Codable {
    let id: String
    let name: String
    let nameEnglish: String

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case nameEnglish = "NameEn"
    }
}
