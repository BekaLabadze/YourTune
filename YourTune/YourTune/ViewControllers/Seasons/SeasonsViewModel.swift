//
//  SeasonsViewModel.swift
//  YourTune
//
//  Created by Beka on 29.01.25.
//

import Foundation

final class SeasonsViewModel {
    var tvShow: TVShow
    var userViewModel: UserViewModel
    
    init(tvShow: TVShow, userViewModel: UserViewModel) {
        self.tvShow = tvShow
        self.userViewModel = userViewModel
    }
    
    var seasonsCount: Int {
        return tvShow.seasons.count
    }
    
    func getSeason(at index: Int) -> Season {
        tvShow.seasons[index]
    }
}
