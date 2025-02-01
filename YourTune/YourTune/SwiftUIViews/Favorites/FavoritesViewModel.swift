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
                self?.fetchAndMapSongs()
            }
        }
    }

    func fetchAndMapSongs() {
        self.favorites.forEach { song in
            DeezerAPI().fetchSongDetails(songName: song.title, artistName: song.artist) { [weak self] result in
                guard let self = self else { return }
                if case .success(let fetchedSong) = result {
                    self.updateFavoritesArray(with: fetchedSong)
                }
            }
        }
    }

    func updateFavoritesArray(with deezer: Deezer) {
        if let index = favorites.firstIndex(where: { $0.title == deezer.title || $0.artist == deezer.artist.name }) {
            DispatchQueue.main.async {
                self.favorites[index].preview = deezer.preview
                self.favorites[index].album = deezer.album
            }
        }
    }
}
