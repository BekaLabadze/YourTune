//
//  SeasonsViewModel.swift
//  YourTune
//
//  Created by Beka on 29.01.25.
//

import Foundation

final class SeasonsViewModel {
    var tvShow: TVShow
    
    init(tvShow: TVShow) {
        self.tvShow = tvShow
    }
    
    var seasonsCount: Int {
        return tvShow.seasons.count
    }
    
    func getSeason(at index: Int) -> Season {
        tvShow.seasons[index]
    }
}
