//
//  ExperienceDetailViewModel.swift
//  Wallie
//
//  Created by Juan Gabriel Borsacchi Marques on 20/08/26.
//

import SwiftUI
import AVKit
import Combine

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
    var isPlayingAudio = false
    var playingAudioURL: URL?
    
    private let displayDuration: Double = 5.0
    private var timerCancellable: AnyCancellable?

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
        timerCancellable?.cancel()
    }

    var allPhotos: [ExperiencePhoto] {
        var photos: [ExperiencePhoto] = []
        for (index, data) in experience.images.enumerated() {
            if let img = UIImage(data: data) {
                photos.append(ExperiencePhoto(id: "cover-\(index)", image: img))
            }
        }
        for (itemIndex, item) in experience.extraItems.enumerated() {
            if case let .images(uiImages) = item.content {
                for (imgIndex, img) in uiImages.enumerated() {
                    photos.append(ExperiencePhoto(id: "extra-\(itemIndex)-\(imgIndex)", image: img))
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
        timerCancellable = Timer.publish(every: 0.05, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateProgress()
            }
    }

    private func updateProgress() {
        guard !allPhotos.isEmpty, !config.showFullScreenCover else { return }
        
        let step = 0.05 / displayDuration
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
            playingAudioURL = url
            audioPlayer = AVPlayer(url: url)
            audioPlayer?.play()
            isPlayingAudio = true
        }
    }

    func stopAudio() {
        audioPlayer?.pause()
        isPlayingAudio = false
    }

    func deleteExperience() {
        onDelete?(experience)
    }
}
