//
//  FavoriteViewModel.swift
//  YourTune
//
//  Created by Beka on 26.01.25.
//

import Foundation


class FavoritesViewModel: ObservableObject {
    var tvShows: [TVShow]
    
    init(tvShows: [TVShow]) {
        self.tvShows = tvShows
    }
    
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
}
