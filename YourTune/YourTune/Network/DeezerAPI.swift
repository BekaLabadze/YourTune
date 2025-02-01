//
//  DeezerAPI.swift
//  YourTune
//
//  Created by Beka on 24.01.25.
//

import Foundation

class DeezerAPI {
    let networkService = DefaultNetworkService(baseURL: "https://api.deezer.com/")

    func fetchSongDetails(songName: String, artistName: String, completion: @escaping (Result<Deezer, Error>) -> Void) {
        
        guard let encodedSongName = songName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let encodedArtistName = artistName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(.failure(NSError(domain: "InvalidSong", code: 400, userInfo: nil)))
            return
        }

        let endpoint = "search?q=\(encodedSongName)%20\(encodedArtistName)"

        networkService.request(endpoint: endpoint) { (result: Result<DeezerResponse, NetworkError>) in
            switch result {
            case .success(let response):
                if let firstSong = response.data.first {
                    completion(.success(firstSong))
                } else {
                    completion(.failure(NSError(domain: "NoResults", code: 404, userInfo: nil)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

}
