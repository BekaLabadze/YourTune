//
//  SongsViewModel.swift
//  YourTune
//
//  Created by Beka on 29.01.25.
//

import Foundation

final class SongsViewModel {
    var songs: [Song]
    var tvShowObject: TVShow
    var userViewModel: UserViewModel
    
    init(songs: [Song], tvShowObject: TVShow, userViewModel: UserViewModel) {
        self.songs = songs
        self.tvShowObject = tvShowObject
        self.userViewModel = userViewModel
    }
    
    var songsCount: Int {
        songs.count
    }
    
    func getSong(at index: Int) -> Song {
        songs[index]
    }
    
    func fetchAndMapSongs(completion: @escaping () -> Void) {
        songs.forEach { song in
            DeezerAPI().fetchSongDetails(songName: song.title) { [weak self] result in
                guard let self = self else { return }
                if case .success(let fetchedSong) = result {
                    self.updateSongArray(with: fetchedSong)
                    DispatchQueue.main.async {
                        completion()
                    }
                }
            }
        }
    }
    
    private func updateSongArray(with deezer: Deezer) {
        if let index = songs.firstIndex(where: { $0.title == deezer.title || $0.artist == deezer.artist.name }) {
            songs[index].preview = deezer.preview
            songs[index].album = deezer.album
        }
    }
    
    func incrementViewCount(for song: Song, in episodeID: String, of tvShowID: String) {
        userViewModel.incrementViewCount(for: song, in: episodeID, of: tvShowID)
    }

    func findEpisodeID(for song: Song) -> String? {
        tvShowObject.seasons.flatMap { $0.episodes }.first { $0.Songs.contains { $0.id == song.id } }?.id
    }
}
