//
//  SplashScreenView.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 20/08/26.
//
import SwiftUI
import AVFoundation

struct VideoSplashScreen: View {
    @Binding var showSplash: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            SplashVideoPlayer(
                videoName: colorScheme == .dark ? "SplashDark" : "SplashLight",
                videoExtension: "mp4"
            ) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showSplash = true
                }
            }
            .ignoresSafeArea()
        }
    }
}

struct SplashVideoPlayer: UIViewRepresentable {
    let videoName: String
    let videoExtension: String
    let onFinish: () -> Void

    func makeUIView(context: Context) -> UIView {
        let view = SplashVideoUIView(videoName: videoName, videoExtension: videoExtension)
        
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: view.player?.currentItem,
            queue: .main
        ) { _ in
            onFinish()
        }
        
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

class SplashVideoUIView: UIView {
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?

    init(videoName: String, videoExtension: String) {
        super.init(frame: .zero)
        
        guard let url = Bundle.main.url(forResource: videoName, withExtension: videoExtension) else {
            print("Vídeo '\(videoName).\(videoExtension)' não encontrado!")
            return
        }
        
        player = AVPlayer(url: url)
        player?.isMuted = true
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspect
        
        if let playerLayer = playerLayer {
            layer.addSublayer(playerLayer)
        }
        
        player?.play()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) não foi implementado")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }
}
