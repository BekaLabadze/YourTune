//
//  PlayerViewModel.swift
//  YourTune
//
//  Created by Beka on 29.01.25.
//

import Foundation
import AVFoundation

final class PlayerViewModel {
    var songArray: [Song]?
    var selectedSong: Song!
    var audioPlayer: AVPlayer?
    var isPlaying: Bool = false
    
    var timeObserverToken: Any?
    
    var progressValue: Double = .zero
    var trimStartTime: Double = .zero
    var trimEndTime: Double = .zero
    var trimState: TrimState = .initial
    var duration: Double = 0
    
    init(
        songArray: [Song]?,
        selectedSong: Song
    ) {
        self.songArray = songArray
        self.selectedSong = selectedSong
    }
    
    func didChangeProgress(value: Float) {
        guard let player = audioPlayer else { return }
        let newTime = CMTime(seconds: Double(value * Float(duration)), preferredTimescale: 1)
        player.seek(to: newTime, toleranceBefore: .zero, toleranceAfter: .zero)
        
        progressValue = Double(value)
    }
    
    private func initPlayer(with url: URL) {
        audioPlayer = AVPlayer(url: url)
        isPlaying = false
    }
    
    func prepareForNextSong() {
        stopObservingProgress()
        if let previewURL = selectedSong.preview {
            initPlayer(with: previewURL)
        }
        startObservingProgress()
        audioPlayer?.play()
        isPlaying = true
    }
    
    func stopObservingProgress() {
        if let token = timeObserverToken {
            audioPlayer?.removeTimeObserver(token)
            timeObserverToken = nil
        }
    }
    
    func startObservingProgress(_ callback: ((Double, Double) -> Void)? = nil) {
        guard let player = audioPlayer else { return }

        if let token = timeObserverToken {
            player.removeTimeObserver(token)
            timeObserverToken = nil
        }

        timeObserverToken = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .main) { [weak self] time in
            guard let self = self else { return }
            
            let duration = player.currentItem?.duration.seconds ?? 0
            self.duration = duration
            let currentTime = time.seconds
            let normalizedCurrectTime = currentTime / duration
            
            callback?(currentTime, normalizedCurrectTime)
        }
    }
    
    func loadInitialSong() {
        guard let previewURL = selectedSong.preview else { return }
        initPlayer(with: previewURL)
        startObservingProgress()
        audioPlayer?.play()
        isPlaying = true
    }
    
    func getDuration() -> Float? {
        guard let player = audioPlayer,
              let currentItem = player.currentItem else { return nil }

        let duration = currentItem.duration.seconds
        guard duration.isFinite else { return nil }
        return Float(duration)
    }
    
    func playButtonTapped() {
        if isPlaying {
            audioPlayer?.pause()
            isPlaying = false
        } else {
            audioPlayer?.play()
            isPlaying = true
        }
    }
    
    func backButtonTapped() {
        guard let currentIndex = songArray?.firstIndex(where: { $0.id == selectedSong.id }),
              currentIndex - 1 >= 0 else { return }
        selectedSong = songArray?[currentIndex - 1]
        prepareForNextSong()
    }
    
    func nextButtonTapped() {
        guard let currentIndex = songArray?.firstIndex(where: { $0.id == selectedSong.id }),
              currentIndex + 1 < songArray?.count ?? 0 else { return }
        selectedSong = songArray?[currentIndex + 1]
        prepareForNextSong()
    }
    
    private func reprocessAudioFile(at fileURL: URL, startTime: Double, endTime: Double, completion: @escaping (URL?) -> Void) {
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("Trimmed audio-\(UUID()).m4a")
        
        if FileManager.default.fileExists(atPath: outputURL.path) {
            try? FileManager.default.removeItem(at: outputURL)
        }
        
        do {
            let audioFile = try AVAudioFile(forReading: fileURL)
            
            let audioFormat = audioFile.processingFormat
            let audioFrameCount = Double(audioFile.length)
            let audioDuration = audioFrameCount / audioFormat.sampleRate
            
            print("Audio duration: \(audioDuration) seconds")

            let safeEndTime = min(endTime, audioDuration)
            
            guard startTime < safeEndTime else {
                print("Invalid time range: Start time is greater than or equal to the end time.")
                completion(nil)
                return
            }
            
            let inputFormat = audioFile.processingFormat
            let startFrame = AVAudioFramePosition(startTime * inputFormat.sampleRate)
            let endFrame = AVAudioFramePosition(safeEndTime * inputFormat.sampleRate)
            let frameCount = AVAudioFrameCount(endFrame - startFrame)
            
            let outputSettings: [String: Any] = [
                AVFormatIDKey: kAudioFormatMPEG4AAC,
                AVSampleRateKey: audioFile.fileFormat.sampleRate,
                AVNumberOfChannelsKey: audioFile.fileFormat.channelCount,
                AVEncoderBitRateKey: 192000
            ]
            
            
            let outputFile = try AVAudioFile(forWriting: outputURL, settings: outputSettings)
            let buffer = AVAudioPCMBuffer(pcmFormat: inputFormat, frameCapacity: frameCount)!
            
            audioFile.framePosition = startFrame
            try audioFile.read(into: buffer, frameCount: frameCount)
            try outputFile.write(from: buffer)
            
            print("Audio trimmed successfully to \(outputURL.path)")
            completion(outputURL)
        } catch {
            print("Failed to process audio file: \(error.localizedDescription)")
            completion(nil)
        }
    }
    
    private func downloadAndReprocessAudio(from url: URL, startTime: Double, endTime: Double, completion: @escaping (Result<URL, Error>) -> Void) {
            let temporaryDirectory = FileManager.default.temporaryDirectory
            let destinationURL = temporaryDirectory.appendingPathComponent("downloadedAudio.m4a")

            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try? FileManager.default.removeItem(at: destinationURL)
            }

            let session = URLSession.shared
            let task = session.downloadTask(with: url) { tempURL, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let tempURL = tempURL else {
                    completion(.failure(NSError(domain: "DownloadError", code: -1, userInfo: [NSLocalizedDescriptionKey: "File not downloaded"])))
                    return
                }

                do {
                    try FileManager.default.moveItem(at: tempURL, to: destinationURL)

                    self.reprocessAudioFile(at: destinationURL, startTime: startTime, endTime: endTime) { reprocessedURL in
                        if let reprocessedURL = reprocessedURL {
                            completion(.success(reprocessedURL))
                        } else {
                            completion(.failure(NSError(domain: "ReprocessError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to reprocess audio file."])))
                        }
                    }
                } catch {
                    completion(.failure(error))
                }
            }

            task.resume()
        }
    
    private func downloadAudio(startTime: Double, endTime: Double, completion: ((Result<URL, Error>) -> Void)? = nil) {
        guard let previewURL = selectedSong?.preview else {
            print("No preview URL available for this song.")
            return
        }
        
        downloadAndReprocessAudio(from: previewURL, startTime: startTime, endTime: endTime) { result in
            completion?(result)
        }
    }
    
    func setTrimState(completion: @escaping ((Result<URL, Error>) -> Void)) {
        switch trimState {
        case .started:
            trimState = .ended
            trimStartTime = progressValue * duration
        case .ended:
            trimState = .initial
            trimEndTime = progressValue * duration
            downloadAudio(startTime: trimStartTime, endTime: trimEndTime) { result in
                completion(result)
            }
        case .initial:
            trimStartTime = .zero
            trimEndTime = .zero
            
            trimState = .started
        }
    }
}

enum TrimState {
    case started
    case ended
    case initial
}
