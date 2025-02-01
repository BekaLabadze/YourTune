//
//  PlayerManager.swift
//  YourTune
//
//  Created by Beka on 24.01.25.
//

import AVFoundation
import UIKit

class PlayerManager: ObservableObject {
    var audioPlayer: AVPlayer?
    var isPlaying: Bool = false
    var timeObserver: Any?

    func initPlayer(with url: URL) {
        audioPlayer = AVPlayer(url: url)
        isPlaying = false
    }

    func playAudio() {
        guard let player = audioPlayer else { return }
        if !isPlaying {
            player.play()
            isPlaying = true
        }
    }

    func pauseAudio() {
        guard let player = audioPlayer else { return }
        if isPlaying {
            player.pause()
            isPlaying = false
        }
    }

    func stopAudio() {
        guard let player = audioPlayer else { return }
        player.pause()
        player.seek(to: .zero)
        isPlaying = false
    }

    func seekToTime(seconds: Double) {
        guard let player = audioPlayer else { return }
        let time = CMTime(seconds: seconds, preferredTimescale: 1)
        player.seek(to: time)
    }

    func startObservingProgress(update: @escaping (Double, Double) -> Void) {
        guard let player = audioPlayer else { return }
        if let timeObserver = timeObserver {
            player.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .main) { time in
            let currentTime = time.seconds
            let duration = player.currentItem?.duration.seconds ?? 0
            update(currentTime, duration)
        }
    }

    func stopObservingProgress() {
        if let timeObserver = timeObserver {
            audioPlayer?.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
    }
}
