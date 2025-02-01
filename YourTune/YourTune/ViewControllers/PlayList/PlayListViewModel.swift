//
//  PlayListViewModel.swift
//  YourTune
//
//  Created by Beka on 29.01.25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class PlayListViewModel: ObservableObject {
    @Published var playlists: [Playlist] = []
    
    private let db = Firestore.firestore()
    
    func fetchPlaylists(completion: @escaping () -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let playlistsRef = db.collection("users").document(userId).collection("playlists")
        
        playlistsRef.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching playlists: \(error.localizedDescription)")
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
            completion()
        }
    }
    
    func addSongToPlaylist(playlistId: String, song: Song, completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let playlistRef = db.collection("users").document(userId).collection("playlists").document(playlistId)

        playlistRef.getDocument { document, error in
            if let error = error {
                print("Error fetching playlist: \(error.localizedDescription)")
                completion(false)
                return
            }

            guard let document = document, document.exists else {
                print("Playlist not found")
                completion(false)
                return
            }

            var updatedSongs: [[String: Any]] = []
            if let existingSongs = document.data()?["songs"] as? [[String: Any]] {
                updatedSongs = existingSongs
            }

            let songData: [String: Any] = [
                "id": song.id,
                "title": song.title,
                "artist": song.artist,
                "preview": song.preview?.absoluteString ?? "",
                "description": song.description,
                "album": ["cover": song.album?.cover.absoluteString ?? ""]
            ]

            updatedSongs.append(songData)

            playlistRef.updateData(["songs": updatedSongs]) { error in
                if let error = error {
                    print("Error adding song: \(error.localizedDescription)")
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
}
