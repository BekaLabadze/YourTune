//
//  ServiceManager.swift
//  YourTune
//
//  Created by Beka on 16.01.25.
//

import Firebase
import FirebaseFirestore
import SwiftUI

class ServiceManager: ObservableObject {
    private var db = Firestore.firestore()

    func fetchAllTVShows(completion: @escaping ([TVShow]) -> Void) {
        db.collection("tvShows").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching TV shows: \(error.localizedDescription)")
                completion([])
                return
            }

            var tvShows: [TVShow] = []

            for document in snapshot?.documents ?? [] {
                let data = document.data()

                var seasonArray: [Season] = []

                if let seasons = data["seasons"] as? [[String: Any]] {
                    for seasonData in seasons {
                        if let seasonObject = self.decodeSeason(data: seasonData) {
                            seasonArray.append(seasonObject)
                        }
                    }
                }

                let tvShow = TVShow(
                    id: document.documentID,
                    image: data["image"] as? String ?? "",
                    title: data["title"] as? String ?? "",
                    seasons: seasonArray
                )

                tvShows.append(tvShow)
            }

            completion(tvShows)
        }
    }

    private func decodeSeason(data: [String: Any]) -> Season? {
        guard let seasonNumber = data["seasonNumber"] as? Int,
              let seasonImage = data["seasonImage"] as? String else {
            return nil
        }

        var episodes: [Episode] = []
        if let episodesArray = data["episodes"] as? [[String: Any]] {
            for episodeData in episodesArray {
                if let episode = decodeEpisode(data: episodeData) {
                    episodes.append(episode)
                }
            }
        }

        return Season(id: UUID().uuidString, seasonNumber: seasonNumber, seasonImage: seasonImage, episodes: episodes)
    }

    private func decodeEpisode(data: [String: Any]) -> Episode? {
        guard let id = data["id"] as? String,
              let title = data["title"] as? String else {
            return nil
        }

        var songs: [Song] = []
        if let songsArray = data["Songs"] as? [[String: Any]] {
            for songData in songsArray {
                if let song = decodeSong(data: songData) {
                    songs.append(song)
                }
            }
        }

        return Episode(id: id, title: title, Songs: songs)
    }

    private func decodeSong(data: [String: Any]) -> Song? {
        guard let id = data["id"] as? String,
              let title = data["title"] as? String,
              let artist = data["artist"] as? String,
              let localAudioname = data["localAudioname"] as? String,
              let description = data["description"] as? String,
              let viewCount = data["viewCount"] as? Int,
              let likeCount = data["likeCount"] as? Int else {
            return nil
        }

        return Song(
            id: id,
            artist: artist,
            title: title,
            description: description,
            localAudioname: localAudioname,
            likeCount: likeCount,
            viewCount: viewCount
            
        )
    }
}
