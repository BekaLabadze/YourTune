//
//  DeezerAPI.swift
//  YourTune
//
//  Created by Beka on 24.01.25.
//

import Foundation

class DeezerAPI {
    
    func fetchSongDetails(songName: String, completion: @escaping (Result<Deezer, Error>) -> Void) {
        guard let encodedSongName = songName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Invalid song name: \(songName)")
            completion(.failure(NSError(domain: "InvalidSongName", code: 400, userInfo: nil)))
            return
        }
        
        let urlString = "https://api.deezer.com/search?q=track:\"\(encodedSongName)\""
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            completion(.failure(NSError(domain: "InvalidURL", code: 400, userInfo: nil)))
            return
        }
        
        print("Fetching details for: \(songName) -> \(urlString)")
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                print("No data returned")
                completion(.failure(NSError(domain: "NoData", code: 500, userInfo: nil)))
                return
            }
            
            do {
                print("Raw response: \(String(data: data, encoding: .utf8) ?? "Invalid data")")
                let searchResponse = try JSONDecoder().decode(DeezerResponse.self, from: data)
                if let firstSong = searchResponse.data.first {
                    completion(.success(firstSong))
                } else {
                    completion(.failure(NSError(domain: "NoResults", code: 404, userInfo: nil)))
                }
            } catch {
                print("Decoding error: \(error.localizedDescription)")
                completion(.failure(error))
            }

        }
        
        task.resume()
    }
}
