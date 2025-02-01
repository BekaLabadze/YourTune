//
//  SessionProvider.swift
//  YourTune
//
//  Created by Beka on 29.01.25.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

final class SessionProvider {
    static var shared = SessionProvider()
    
    private init() {}
    private let db = Firestore.firestore()
    
    var user: User?
    var favorites: [Song] = []
    
    func setUser(_ user: User?) {
        self.user = user
    }
    
    func removeFavorite(song: Song, in episodeID: String, of tvShowID: String) {
        guard let userId = SessionProvider.shared.user?.id else { return }
        db.collection("users").document(userId).collection("favorites").document(song.id).delete { [weak self] error in
            if let error = error {
                print("Error removing from favorites: \(error.localizedDescription)")
                return
            }
            
            DispatchQueue.main.async {
                self?.favorites.removeAll { $0.id == song.id }
                NotificationCenter.default.post(name: .favoritesUpdated, object: nil)
            }
        }
        
        decrementLikeCount(for: song, in: episodeID, of: tvShowID)
    }
    
    func decrementLikeCount(for song: Song, in episodeID: String, of tvShowID: String) {
        let tvShowRef = db.collection("tvShows").document(tvShowID)
        
        tvShowRef.getDocument { document, error in
            if let error = error {
                print("Error fetching TV show: \(error.localizedDescription)")
                return
            }
            
            guard let document = document, document.exists else {
                print("TV show document not found.")
                return
            }
            
            var seasons = document.data()?["seasons"] as? [[String: Any]] ?? []
            
            for seasonIndex in 0..<seasons.count {
                var episodes = seasons[seasonIndex]["episodes"] as? [[String: Any]] ?? []
                
                for episodeIndex in 0..<episodes.count {
                    if episodes[episodeIndex]["id"] as? String == episodeID {
                        var songs = episodes[episodeIndex]["Songs"] as? [[String: Any]] ?? []
                        
                        if let songIndex = songs.firstIndex(where: { $0["id"] as? String == song.id }) {
                            var currentLikeCount = songs[songIndex]["likeCount"] as? Int ?? 0
                            currentLikeCount = max(0, currentLikeCount - 1)
                            songs[songIndex]["likeCount"] = currentLikeCount
                            
                            episodes[episodeIndex]["Songs"] = songs
                            seasons[seasonIndex]["episodes"] = episodes
                            
                            tvShowRef.updateData(["seasons": seasons]) { error in
                                if let error = error {
                                    print("Error decrementing like count: \(error.localizedDescription)")
                                } else {
                                    print("Successfully decremented like count for \(song.title) to \(currentLikeCount).")
                                }
                            }
                            return
                        }
                    }
                }
            }
            
            print("Song not found in any episodes.")
        }
    }
    
    func isFavorite(_ song: Song) -> Bool {
        return favorites.contains(where: { $0.id == song.id })
    }
    
    func toggleFavorite(for song: Song, in episodeID: String, of tvShowID: String) {
        guard let userId = SessionProvider.shared.user?.id else { return }
        
        let isCurrentlyFavorited = isFavorite(song)

        if isCurrentlyFavorited {
            removeFavorite(song: song, in: episodeID, of: tvShowID)
        } else {
            addFavorite(song: song, in: episodeID, of: tvShowID)
        }
        
        NotificationCenter.default.post(name: .favoritesUpdated, object: nil)
    }

    
    func addFavorite(song: Song, in episodeID: String, of tvShowID: String) {
        guard let userId = SessionProvider.shared.user?.id else { return }
        
        let songData: [String: Any] = [
            "id": song.id,
            "title": song.title,
            "artist": song.artist,
            "description": song.description,
            "localAudioname": song.localAudioname,
            "likeCount": song.likeCount,
            "viewCount": song.viewCount
        ]
        
        db.collection("users").document(userId).collection("favorites").document(song.id).setData(songData) { [weak self] error in
            if let error = error {
                print("Error adding to favorites: \(error.localizedDescription)")
                return
            }
            
            DispatchQueue.main.async {
                self?.favorites.append(song)
                NotificationCenter.default.post(name: .favoritesUpdated, object: nil)
            }
        }
        
        incrementLikeCount(for: song, in: episodeID, of: tvShowID)
    }
    
    func incrementLikeCount(for song: Song, in episodeID: String, of tvShowID: String) {
        let tvShowRef = db.collection("tvShows").document(tvShowID)
        
        tvShowRef.getDocument { document, error in
            if let error = error {
                print("Error fetching TV show: \(error.localizedDescription)")
                return
            }
            
            guard let document = document, document.exists else {
                print("TV show document not found.")
                return
            }
            
            var seasons = document.data()?["seasons"] as? [[String: Any]] ?? []
            
            for seasonIndex in 0..<seasons.count {
                var episodes = seasons[seasonIndex]["episodes"] as? [[String: Any]] ?? []
                
                for episodeIndex in 0..<episodes.count {
                    if episodes[episodeIndex]["id"] as? String == episodeID {
                        var songs = episodes[episodeIndex]["Songs"] as? [[String: Any]] ?? []
                        
                        if let songIndex = songs.firstIndex(where: { $0["id"] as? String == song.id }) {
                            var currentLikeCount = songs[songIndex]["likeCount"] as? Int ?? 0
                            currentLikeCount += 1
                            songs[songIndex]["likeCount"] = currentLikeCount
                            
                            episodes[episodeIndex]["Songs"] = songs
                            seasons[seasonIndex]["episodes"] = episodes
                            
                            tvShowRef.updateData(["seasons": seasons]) { error in
                                if let error = error {
                                    print("Error updating like count: \(error.localizedDescription)")
                                } else {
                                    print("Successfully incremented like count for \(song.title) to \(currentLikeCount).")
                                }
                            }
                            return
                        }
                    }
                }
            }
            
            print("Song not found in any episodes.")
        }
    }
    
    func fetchFavorites(completion: (([Song]) -> Void)? = nil)  {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).collection("favorites").getDocuments { [weak self] snapshot, error in
            if let error = error {
                print("Error fetching favorites: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            var fetchedFavorites: [Song] = []
            let group = DispatchGroup()

            for document in documents {
                let data = document.data()
                if let id = data["id"] as? String,
                   let title = data["title"] as? String,
                   let artist = data["artist"] as? String,
                   let description = data["description"] as? String,
                   let localAudioname = data["localAudioname"] as? String {
                    
                    var song = Song(
                        id: id,
                        artist: artist,
                        title: title,
                        description: description,
                        localAudioname: localAudioname
                    )
                    
                    group.enter()
                    DeezerAPI().fetchSongDetails(songName: title, artistName: artist) { result in
                        if case .success(let deezerSong) = result {
                            song.album = deezerSong.album
                        }
                        fetchedFavorites.append(song)
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: .main) {
                DispatchQueue.main.async {
                    self?.favorites = fetchedFavorites
                    completion?(fetchedFavorites)
                }
            }
        }
    }
    
    func incrementViewCount(for song: Song, in episodeID: String, of tvShowID: String) {
        let tvShowRef = db.collection("tvShows").document(tvShowID)
        
        tvShowRef.getDocument { document, error in
            if let error = error {
                print("Error fetching TV show: \(error.localizedDescription)")
                return
            }
            
            guard let document = document, document.exists else {
                print("TV show document not found.")
                return
            }
            
            var seasons = document.data()?["seasons"] as? [[String: Any]] ?? []
            
            for seasonIndex in 0..<seasons.count {
                var episodes = seasons[seasonIndex]["episodes"] as? [[String: Any]] ?? []
                
                for episodeIndex in 0..<episodes.count {
                    if episodes[episodeIndex]["id"] as? String == episodeID {
                        var songs = episodes[episodeIndex]["Songs"] as? [[String: Any]] ?? []
                        
                        if let songIndex = songs.firstIndex(where: { $0["id"] as? String == song.id }) {
                            var currentViewCount = songs[songIndex]["viewCount"] as? Int ?? 0
                            currentViewCount += 1
                            songs[songIndex]["viewCount"] = currentViewCount
                            
                            episodes[episodeIndex]["Songs"] = songs
                            seasons[seasonIndex]["episodes"] = episodes
                            
                            tvShowRef.updateData(["seasons": seasons]) { error in
                                if let error = error {
                                    print("Error updating view count: \(error.localizedDescription)")
                                } else {
                                    print("Successfully incremented view count for \(song.title) to \(currentViewCount).")
                                }
                            }
                            return
                        }
                    }
                }
            }
            
            print("Song not found in any episodes.")
        }
    }
    
    func fetchAndMapSongs(completion: (([Song]) -> Void)? = nil) {
        self.favorites.forEach { song in
            DeezerAPI().fetchSongDetails(songName: song.title, artistName: song.artist) { [weak self] result in
                guard let self = self else { return }
                if case .success(let fetchedSong) = result {
                    self.updateFavouritesArray(with: fetchedSong)
                }
            }
        }
    }
    
    func updateFavouritesArray(with deezer: Deezer) {
        if let index = favorites.firstIndex(where: { $0.title == deezer.title || $0.artist == deezer.artist.name }) {
            DispatchQueue.main.async {
                self.favorites[index].preview = deezer.preview
                self.favorites[index].album = deezer.album
            }
        }
    }
}
