//
//  PlayListViewModel.swift
//  YourTune
//
//  Created by Beka on 30.01.25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class PlaylistViewModelSwiftUI: ObservableObject {
    @Published var playlists: [Playlist] = []
    @Published var songs: [Song] = []
    @Published var isSaving = false

    private let db = Firestore.firestore()
    private var playlistListener: ListenerRegistration?
    private var songListener: ListenerRegistration?
    
    func fetchAndMapSongs() {
        songs.forEach { song in
            DeezerAPI().fetchSongDetails(songName: song.title, artistName: song.artist) { [weak self] result in
                guard let self = self else { return }
                if case .success(let fetchedSong) = result {
                    self.updateSongArray(with: fetchedSong)
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
    
    func startListeningForPlaylists() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let playlistsRef = db.collection("users").document(userId).collection("playlists")

        playlistListener?.remove()
        playlistListener = playlistsRef.addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error listening to playlists: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else { return }
            self.playlists = documents.compactMap { doc in
                let data = doc.data()
                if let name = data["name"] as? String {
                    return Playlist(id: doc.documentID, name: name)
                }
                return nil
            }
        }
    }

    func stopListeningForPlaylists() {
        playlistListener?.remove()
        playlistListener = nil
    }

    func fetchSongs(for playlistId: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let playlistRef = Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("playlists")
            .document(playlistId)

        playlistRef.getDocument { documentSnapshot, error in
            if let error = error {
                print("❌ Error fetching songs: \(error.localizedDescription)")
                return
            }

            guard let document = documentSnapshot, document.exists else {
                print("❌ Playlist not found")
                return
            }

            if let songsArray = document.data()?["songs"] as? [[String: Any]] {
                let songs = songsArray.compactMap { data -> Song? in
                    if let id = data["id"] as? String,
                       let title = data["title"] as? String,
                       let artist = data["artist"] as? String,
                       let previewURL = URL(string: data["preview"] as? String ?? ""),
                       let albumData = data["album"] as? [String: Any],
                       let albumCoverURL = URL(string: albumData["cover"] as? String ?? "") {

                        let album = Album(cover: albumCoverURL)
                        return Song(id: id, artist: artist, title: title, preview: previewURL, album: album, description: data["description"] as? String ?? "", localAudioname: "", likeCount: 0, viewCount: 0)
                    }
                    return nil
                }

                self.songs = songs
                self.fetchAndMapSongs()
            } else {
                print("❌ No songs found in playlist")
            }
        }
    }


    func createPlaylist(playListName: String, completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let playlistRef = db.collection("users").document(userId).collection("playlists").document()

        let newPlaylist: [String: Any] = [
            "name": playListName,
            "songs": []
        ]

        isSaving = true
        playlistRef.setData(newPlaylist) { error in
            DispatchQueue.main.async {
                self.isSaving = false
                if let error = error {
                    print("Error creating playlist: \(error.localizedDescription)")
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
}
