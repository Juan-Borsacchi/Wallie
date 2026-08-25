//
//  ExperienceDetailViewModel.swift
//  Wallie
//
//  Created by Juan Gabriel Borsacchi Marques on 20/08/26.
//

import SwiftUI
import AVKit
import Observation

@Observable
final class ExperienceDetailViewModel {
    var experience: Experience
    var onSave: (Experience) -> Void
    var onDelete: ((Experience) -> Void)?
    
    var isShowingEdit = false
    var isShowingDeleteAlert = false
    var selectedImageIndex = 0
    var config: PhotoHeroEffectConfig<ExperiencePhoto> = .init()
    var progress: Double = 0.0
    var selectedTab = 0
    
    private var audioPlayer: AVPlayer?
    private var playerItemObserver: NSObjectProtocol?
    var isPlayingAudio = false
    var playingAudioURL: URL?
    
    private let displayDuration: Double = 5.0
    private var timerTask: Task<Void, Never>?
    
    init(
        experience: Experience,
        onSave: @escaping (Experience) -> Void,
        onDelete: ((Experience) -> Void)? = nil
    ) {
        self.experience = experience
        self.onSave = onSave
        self.onDelete = onDelete
        startTimer()
    }
    
    deinit {
        stopAudio()
        timerTask?.cancel()
    }
    
    var allPhotos: [ExperiencePhoto] {
        var photos: [ExperiencePhoto] = []
        for (index, data) in experience.images.enumerated() {
            if let img = UIImage(data: data) {
                photos.append(ExperiencePhoto(id: "cover-\(index)", image: img))
            }
        }
        for (itemIndex, item) in experience.extraItems.enumerated() {
            if case let .images(dataArray) = item.content {
                for (imgIndex, data) in dataArray.enumerated() {
                    if let img = UIImage(data: data) {
                        photos.append(ExperiencePhoto(id: "extra-\(itemIndex)-\(imgIndex)", image: img))
                    }
                }
            }
        }
        return photos
    }
    
    var audioURLs: [URL] {
        experience.extraItems.compactMap { item in
            if case .audio(let url) = item.content { return url }
            return nil
        }
    }
    
    var hasAudio: Bool { !audioURLs.isEmpty }
    var hasMood: Bool { experience.quality != nil || experience.emotion != nil }
    
    func startTimer() {
        timerTask?.cancel()
        timerTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 100_000_000)
                
                guard let self = self, !self.isShowingEdit, !self.isShowingDeleteAlert else { continue }
                self.updateProgress()
            }
        }
    }
    
    private func updateProgress() {
        guard !allPhotos.isEmpty, !config.showFullScreenCover else { return }
        
        let step = 0.1 / displayDuration
        if progress + step >= 1.0 {
            progress = 0.0
            selectedImageIndex = (selectedImageIndex + 1) % allPhotos.count
        } else {
            progress += step
        }
    }
    
    func toggleAudioPlay(url: URL) {
            if isPlayingAudio && playingAudioURL == url {
                stopAudio()
            } else {
                stopAudio() // Para qualquer áudio anterior antes de iniciar um novo
                
                playingAudioURL = url
                let item = AVPlayerItem(url: url)
                audioPlayer = AVPlayer(playerItem: item)
                
                // Observa quando o áudio chega ao fim
                playerItemObserver = NotificationCenter.default.addObserver(
                    forName: .AVPlayerItemDidPlayToEndTime,
                    object: item,
                    queue: .main
                ) { [weak self] _ in
                    self?.handleAudioDidFinish()
                }
                
                audioPlayer?.play()
                isPlayingAudio = true
            }
        }
        
        private func handleAudioDidFinish() {
            audioPlayer?.seek(to: .zero) // Reseta o player para o início
            isPlayingAudio = false
            playingAudioURL = nil
            removePlayerObserver()
        }
        
        func stopAudio() {
            audioPlayer?.pause()
            audioPlayer = nil
            isPlayingAudio = false
            playingAudioURL = nil
            removePlayerObserver()
        }
        
        private func removePlayerObserver() {
            if let observer = playerItemObserver {
                NotificationCenter.default.removeObserver(observer)
                playerItemObserver = nil
            }
        }
        
        func deleteExperience() {
            onDelete?(experience)
        }
    }
