//
//  SongsViewModel.swift
//  YourTune
//
//  Created by Beka on 29.01.25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

final class SongsViewModel {
    var songs: [Song]
    var tvShowObject: TVShow
    
    init(songs: [Song], tvShowObject: TVShow) {
        self.songs = songs
        self.tvShowObject = tvShowObject
    }
    
    var songsCount: Int {
        songs.count
    }
    
    func getSong(at index: Int) -> Song {
        songs[index]
    }
    
    func fetchAndMapSongs(completion: @escaping () -> Void) {
        let queue = DispatchQueue(label: "deezer.api.queue", qos: .userInitiated)
        let group = DispatchGroup()

        for (index, song) in songs.enumerated() {
            group.enter()
            
            queue.asyncAfter(deadline: .now() + Double(index) * 0.3) {
                print("🎵 Fetching song: \(song.title) by \(song.artist)")

                DeezerAPI().fetchSongDetails(songName: song.title, artistName: song.artist) { [weak self] result in
                    guard let self = self else {
                        group.leave()
                        return
                    }

                    if case .success(let fetchedSong) = result {
                        self.updateSongArray(with: fetchedSong)
                    } else {
                        print("Failed to fetch preview for \(song.title)")
                    }

                    group.leave()
                }
            }
        }

        group.notify(queue: .main) {
            completion()
        }
    }

    private func updateSongArray(with deezer: Deezer) {
        if let index = songs.firstIndex(where: {
            $0.title.lowercased() == deezer.title.lowercased() &&
            $0.artist.lowercased() == deezer.artist.name.lowercased()
        }) {
            songs[index].preview = deezer.preview
            songs[index].album = deezer.album

            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name("SongsUpdated"), object: nil)
            }
        } else {
            print("Error")
        }
    }
    
    func incrementViewCount(for song: Song, in episodeID: String, of tvShowID: String) {
        SessionProvider.shared.incrementViewCount(for: song, in: episodeID, of: tvShowID)
    }
    
    func findEpisodeID(for song: Song) -> String? {
        tvShowObject.seasons.flatMap { $0.episodes }.first { $0.Songs.contains { $0.id == song.id } }?.id
    }
}
