//
//  NetworkError.swift
//  YourTune
//
//  Created by Beka on 30.01.25.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingError(Error)
}
