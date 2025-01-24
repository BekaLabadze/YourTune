//
//  UserViewModel.swift
//  YourTune
//
//  Created by Beka on 13.01.25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class UserViewModel: ObservableObject {
    @Published var user: User?
    @Published var favorites: [Song] = []
    @Published var errorMessage: String?
    @Published var isAuthenticated = false
    @Published var allSongs: [Song] = []
    
    @Published var exploreSongs: [Song] = []
    
    private let db = Firestore.firestore()
    
    init() {
        fetchUser()
        fetchFavorites()
        fetchAllSongsWithStats { _ in }
    }
    
    func signUp(email: String, password: String, username: String) {
        guard validateEmail(email), validatePassword(password), validateUsername(username) else { return }
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                return
            }
            guard let userId = authResult?.user.uid else { return }
            let userData: [String: Any] = ["email": email, "username": username, "createdAt": Timestamp()]
            self?.db.collection("users").document(userId).setData(userData) { error in
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.isAuthenticated = true
                    self?.fetchUser()
                }
            }
        }
    }
    
    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] _, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                return
            }
            self?.isAuthenticated = true
            self?.fetchUser()
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            user = nil
            favorites = []
        } catch {
            errorMessage = "Error signing out: \(error.localizedDescription)"
        }
    }
    
    func fetchUser() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(userId).getDocument { [weak self] document, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                return
            }
            if let data = document?.data(),
               let email = data["email"] as? String,
               let username = data["username"] as? String {
                self?.user = User(id: userId, email: email, username: username)
                self?.fetchFavorites()
            }
        }
    }
    
    func isFavorite(_ song: Song) -> Bool {
        return favorites.contains(where: { $0.id == song.id })
    }
    
    func toggleFavorite(for song: Song, in episodeID: String, of tvShowID: String) {
        guard let userId = user?.id else { return }
        
        let isCurrentlyFavorited = isFavorite(song)
        
        if isCurrentlyFavorited {
            removeFavorite(song: song, in: episodeID, of: tvShowID)
        } else {
            addFavorite(song: song, in: episodeID, of: tvShowID)
        }
    }
    
    func addFavorite(song: Song, in episodeID: String, of tvShowID: String) {
        guard let userId = user?.id else { return }
        
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
    
    func removeFavorite(song: Song, in episodeID: String, of tvShowID: String) {
        guard let userId = user?.id else { return }
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
    
    func fetchFavorites() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).collection("favorites").getDocuments { [weak self] snapshot, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            var fetchedFavorites: [Song] = []
            for document in documents {
                let data = document.data()
                if let id = data["id"] as? String,
                   let title = data["title"] as? String,
                   let artist = data["artist"] as? String,
                   let description = data["description"] as? String,
                   let localAudioname = data["localAudioname"] as? String {
                    let song = Song(
                        id: id,
                        artist: artist,
                        title: title,
                        description: description,
                        localAudioname: localAudioname
                    )
                    fetchedFavorites.append(song)
                }
            }
            DispatchQueue.main.async {
                self?.favorites = fetchedFavorites
            }
        }
    }
    
    func fetchAllSongsWithStats(completion: @escaping ([Song]) -> Void) {
        db.collection("songs").getDocuments { [weak self] snapshot, error in
            if let error = error {
                completion([])
                return
            }
            guard let documents = snapshot?.documents else {
                completion([])
                return
            }
            var songsWithStats: [Song] = []
            for document in documents {
                let data = document.data()
                let id = document.documentID
                if let title = data["title"] as? String,
                   let artist = data["artist"] as? String,
                   let likeCount = data["likeCount"] as? Int,
                   let viewCount = data["viewCount"] as? Int {
                    let song = Song(
                        id: id,
                        artist: artist,
                        title: title,
                        description: data["description"] as? String ?? "",
                        localAudioname: data["localAudioname"] as? String ?? "",
                        likeCount: likeCount,
                        viewCount: viewCount
                    )
                    songsWithStats.append(song)
                }
            }
            DispatchQueue.main.async {
                self?.allSongs = songsWithStats
                completion(songsWithStats)
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
    
    private func updateSongField(for song: Song, in episodeID: String, of tvShowID: String, field: String, increment: Int) {
        let tvShowRef = db.collection("tvShows").document(tvShowID)
        tvShowRef.getDocument { document, error in
            if let error = error {
                return
            }
            guard let document = document, document.exists else {
                return
            }
            var seasons = document.data()?["seasons"] as? [[String: Any]] ?? []
            for seasonIndex in 0..<seasons.count {
                var episodes = seasons[seasonIndex]["episodes"] as? [[String: Any]] ?? []
                for episodeIndex in 0..<episodes.count {
                    if episodes[episodeIndex]["id"] as? String == episodeID {
                        var songs = episodes[episodeIndex]["Songs"] as? [[String: Any]] ?? []
                        if let songIndex = songs.firstIndex(where: { $0["id"] as? String == song.id }) {
                            var currentCount = songs[songIndex][field] as? Int ?? 0
                            currentCount += increment
                            songs[songIndex][field] = currentCount
                            episodes[episodeIndex]["Songs"] = songs
                            seasons[seasonIndex]["episodes"] = episodes
                            tvShowRef.updateData(["seasons": seasons]) { error in
                            }
                            return
                        }
                    }
                }
            }
        }
    }
    
    private func validateEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        if emailPredicate.evaluate(with: email) {
            return true
        } else {
            errorMessage = "Invalid email address."
            return false
        }
    }
    
    private func validatePassword(_ password: String) -> Bool {
        if password.count >= 6 {
            return true
        } else {
            errorMessage = "Password must be at least 6 characters long."
            return false
        }
    }
    
    private func validateUsername(_ username: String) -> Bool {
        if !username.isEmpty && username.count >= 3 {
            return true
        } else {
            errorMessage = "Username must be at least 3 characters long."
            return false
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
