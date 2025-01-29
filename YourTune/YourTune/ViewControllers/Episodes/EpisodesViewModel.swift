//
//  EpisodesViewModel.swift
//  YourTune
//
//  Created by Beka on 29.01.25.
//

import Foundation

final class EpisodesViewModel {
    var season: Season!
    var tvShowObject: TVShow!
    
    init(season: Season!, tvShowObject: TVShow!) {
        self.season = season
        self.tvShowObject = tvShowObject
    }
    
    func getEpisode(index: Int) -> Episode {
        season.episodes[index]
    }
}
