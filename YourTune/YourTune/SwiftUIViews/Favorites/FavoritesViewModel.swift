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
    @Published var selectedSongs: Song?
    private var serviceModel = ServiceManager()
    
    @Published var favorites: [Song] = SessionProvider.shared.favorites
    
    func findIDs(for song: Song) -> (episodeID: String?, tvShowID: String?) {
        for tvShow in tvShows {
            for season in tvShow.seasons {
                for episode in season.episodes {
                    if episode.Songs.contains(where: { $0.id == song.id }) {
                        return (episode.id, tvShow.id)
                    }
                }
            }
        }
        return (nil, nil)
    }
    
    func fetchTVShows() {
        serviceModel.fetchAllTVShows { [weak self] tvShows in
            self?.tvShows = tvShows
        }
    }
    
    func toggleFavorite(song: Song) {
        let ids = findIDs(for: song)
        SessionProvider.shared.toggleFavorite(for: song, in: ids.episodeID ?? "", of: ids.tvShowID ?? "")
    }
    
    func fetchFavorites() {
        SessionProvider.shared.fetchFavorites { [weak self] favorites in
            DispatchQueue.main.async {
                self?.favorites = favorites
            }
        }
    }
}
