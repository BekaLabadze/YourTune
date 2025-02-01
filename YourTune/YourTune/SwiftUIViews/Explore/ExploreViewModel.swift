//
//  ExploreViewModel.swift
//  YourTune
//
//  Created by Beka on 29.01.25.
//

import Foundation

class ExploreViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var filterOption: FilterOption = .mostViewed
    @Published var tvShows: [TVShow] = []
    @Published private var songs: [Song] = []
    @Published var filteredSongs: [Song] = []
    @Published var selectedSongs: Song?
    
    func fetchTvShows() {
        ServiceManager().fetchAllTVShows { [weak self] tvShows in
            guard let self else { return }
            self.tvShows = tvShows
            
            songs = tvShows.flatMap { $0.seasons }
                .flatMap { $0.episodes }
                .flatMap { $0.Songs }
                .reduce(into: [String: Song]()) { uniqueSongs, song in
                    uniqueSongs[song.id] = song
                }
                .map { $0.value }
            
            filteredSongs = songs
            
            fetchAndMapSongs()
        }
    }
    
    func filterAndSortSongs() {
        guard !searchText.isEmpty else {
            filteredSongs = songs
            return
        }
        filteredSongs = filteredSongs.filter { $0.title.lowercased().contains(searchText.lowercased()) }
        
        switch filterOption {
              case .mostViewed:
                  filteredSongs.sort { $0.viewCount > $1.viewCount }
              case .mostLiked:
            filteredSongs.sort { $0.likeCount > $1.likeCount }
              }
        }
    
    func fetchAndMapSongs() {
        self.songs.forEach { song in
            DeezerAPI().fetchSongDetails(songName: song.title, artistName: song.artist) { [weak self] result in
                guard let self = self else { return }
                if case .success(let fetchedSong) = result {
                    self.updateSongArray(with: fetchedSong)
                }
            }
        }
        filteredSongs = songs
    }
    
    func updateSongArray(with deezer: Deezer) {
        if let index = songs.firstIndex(where: { $0.title == deezer.title || $0.artist == deezer.artist.name }) {
            DispatchQueue.main.async {
                self.songs[index].preview = deezer.preview
                self.songs[index].album = deezer.album
                self.updateFilteredSongs()
            }
        }
    }
    
    func updateFilteredSongs() {
        for song in songs {
            for filteredSong in filteredSongs {
                if song.title == filteredSong.title {
                    if let index = filteredSongs.firstIndex(where: { $0.title == filteredSong.title }) {
                        DispatchQueue.main.async {
                            self.filteredSongs[index].preview = song.preview
                            self.filteredSongs[index].album = song.album
                        }
                    }
                }
            }
        }
    }
    
    func getCoverURL(song: Song) -> URL? {
         if let urlString = song.album?.cover.absoluteString,
            let url = URL(string: urlString) {
             return url
         } else {
             return nil
         }
     }
}
