//
//  Model.swift
//  YourTune
//
//  Created by Beka on 13.01.25.
//

import Foundation

struct TVShow: Identifiable, Codable {
    var id: String
    var image: String
    var title: String
    var seasons: [Season]
}

struct Season: Identifiable, Codable {
    var id: String
    var seasonNumber: Int
    var seasonImage: String
    var episodes: [Episode]
}

struct Episode: Identifiable, Codable {
    var id: String
    var title: String
    var Songs: [Song]
}

struct User: Identifiable {
    let id: String
    let email: String
    let username: String
}

struct Playlist: Identifiable, Hashable {
    let id = UUID()
    var name: String?
    var playListSongs: [Song]?
}

struct Song: Identifiable, Codable, Hashable {
    var id: String
    var artist: String
    var title: String
    var preview: URL?
    var album: Album?
    var description: String
    var localAudioname: String
    var likeCount: Int = 0
    var viewCount: Int = 0
}

struct DeezerResponse: Codable {
    var data: [Deezer]
}

struct Deezer: Codable, Hashable, Equatable {
    var title: String
    var artist: Artist
    var album: Album
    var preview: URL?
}
struct Artist: Codable, Equatable, Hashable {
    var name: String
}

struct Album: Codable, Equatable, Hashable {
    var cover: URL
}

