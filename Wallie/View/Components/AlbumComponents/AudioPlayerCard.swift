//
//  AudioPlayerCardView.swift
//  Wallie
//
//  Created by Juan Gabriel Borsacchi Marques on 17/08/26.
//

import SwiftUI
import AVFoundation
internal import Combine

class AudioPlayerManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var isPlaying = false
    @Published var duration: TimeInterval = 0
    
    private var audioPlayer: AVAudioPlayer?
    
    func togglePlay(url: URL) {
        if isPlaying {
            audioPlayer?.pause()
            isPlaying = false
        } else {
            do {
                if audioPlayer == nil {
                    audioPlayer = try AVAudioPlayer(contentsOf: url)
                    audioPlayer?.delegate = self
                    duration = audioPlayer?.duration ?? 0
                }
                audioPlayer?.play()
                isPlaying = true
            } catch {
                print("Erro ao tocar áudio: \(error)")
            }
        }
    }
    
    func stopAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isPlaying = false
            self.audioPlayer?.currentTime = 0
        }
    }
}

struct AudioPlayerCardView: View {
    let audioURL: URL
    var onDelete: () -> Void
    
    @StateObject private var playerManager = AudioPlayerManager()
    @State private var sampleAmplitudes: [CGFloat] = [
        0.2, 0.4, 0.7, 0.5, 0.3, 0.8, 1.0, 0.6, 0.4, 0.2,
        0.5, 0.9, 0.7, 0.3, 0.6, 0.8, 0.4, 0.2, 0.5, 0.7
    ]
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                Button(action: {
                    playerManager.togglePlay(url: audioURL)
                }) {
                    Image(systemName: playerManager.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(Circle().fill(Color.indigo))
                }
                
                Text(formattedDuration)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Image(systemName: "quote.bubble")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Button(action: {
                    playerManager.stopAudio()
                    onDelete()
                }) {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            AudioWaveformView(samples: sampleAmplitudes, barColor: .indigo)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.indigo.opacity(0.18))
        )
        .onDisappear {
            playerManager.stopAudio()
        }
    }
    
    private var formattedDuration: String {
        let duration = playerManager.duration
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
