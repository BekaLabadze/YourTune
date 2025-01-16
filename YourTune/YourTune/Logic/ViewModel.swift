//
//  ViewModel.swift
//  YourTune
//
//  Created by Beka on 16.01.25.
//

import SwiftUI
import AVFoundation
import UIKit

class ViewModel: ObservableObject {
    @Published var tvShows: [TVShow] = []
    @Published var filteredTVShows: [TVShow] = []
    @Published var searchQuery: String = ""
    private var serviceModel = ServiceManager()
    var isPlaying: Bool = false
    var songs: [Song] = []
    var selectedSong: Song?
    
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
