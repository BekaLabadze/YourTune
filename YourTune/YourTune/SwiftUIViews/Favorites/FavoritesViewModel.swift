//
//  FavoritesViewModel.swift
//  YourTune
//
//  Created by Beka on 29.01.25.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore


class FavoritesViewModel: ObservableObject {
    @Published var tvShows: [TVShow] = []
    
    var favorites: [Song] {
        SessionProvider.shared.favorites
    }
    
    private var serviceModel = ServiceManager()
    
    
    private let db = Firestore.firestore()
    
    func findIDs(for song: Song) -> (episodeID: String, tvShowID: String)? {
        for tvShow in tvShows {
            for season in tvShow.seasons {
                for episode in season.episodes {
                    if episode.Songs.contains(where: { $0.id == song.id }) {
                        return (episode.id, tvShow.id)
                    }
                }
            }
        }
        return nil
    }
    
    func fetchTVShows() {
        serviceModel.fetchAllTVShows { [weak self] tvShows in
            self?.tvShows = tvShows
        }
    }
    
    func removeFavorite(song: Song, in episodeID: String, of tvShowID: String) {
        SessionProvider.shared.removeFavorite(song: song, in:episodeID, of: tvShowID)
    }
}
