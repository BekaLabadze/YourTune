//
//  TVShowViewModel.swift
//  YourTune
//
//  Created by Beka on 29.01.25.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

final class TvShowsViewModel: ObservableObject {
    @Published var user: User?
    @Published var tvShows: [TVShow] = []
    @Published var filteredTVShows: [TVShow] = []
    @Published var searchQuery: String = ""
    @Published var errorMessage: String?
    private var serviceModel = ServiceManager()
    var songs: [Song] = []
    
    private let db = Firestore.firestore()

    init() {
        fetchTVShows()
        getSongs()
    }
    
    func fetchTVShows() {
        serviceModel.fetchAllTVShows { [weak self] tvShows in
            self?.tvShows = tvShows
            self?.filteredTVShows = tvShows
        }
    }
    
    func getSongs() {
        for fetchedShowsArray in tvShows {
            let fetchedShows = fetchedShowsArray.seasons
            for fetchedSeason in fetchedShows {
                let fetchedEpisodes = fetchedSeason.episodes
                for fetchedSongs in fetchedEpisodes {
                    let songsArray = fetchedSongs.Songs
                    songs = songsArray
                    
                }
            }
        }
    }
    
    func filterTVShows() {
        if searchQuery.isEmpty {
            filteredTVShows = tvShows
        } else {
            filteredTVShows = tvShows.filter {
                $0.title.lowercased().contains(searchQuery.lowercased())
            }
        }
    }
}
