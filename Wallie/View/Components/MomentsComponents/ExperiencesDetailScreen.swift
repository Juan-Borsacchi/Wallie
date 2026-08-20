//
//  ExperienceDetailScreen.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 17/08/26.
//

import SwiftUI
import AVKit
import Combine

struct ExperiencePhoto: Identifiable, PhotoProtocol, Hashable {
    let id: String
    let image: UIImage
}

struct ExperienceDetailScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State var experience: Experience
    let onSave: (Experience) -> Void
    
    @State private var isShowingEdit = false
    @State private var selectedImageIndex = 0
    @State private var config: PhotoHeroEffectConfig<ExperiencePhoto> = .init()
    
    @State private var progress: Double = 0.0
    
    @State private var progressTimer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    private let displayDuration: Double = 5.0 // Tempo em segundos por foto
    
    @State private var selectedTab = 0
    
    @State private var audioPlayer: AVPlayer?
    @State private var isPlayingAudio = false
    @State private var playingAudioURL: URL?
    
    private var allPhotos: [ExperiencePhoto] {
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
    
    private var audioURLs: [URL] {
        experience.extraItems.compactMap { item in
            if case .audio(let url) = item.content { return url }
            return nil
        }
    }
    
    private var hasAudio: Bool { !audioURLs.isEmpty }
    private var hasMood: Bool { experience.quality != nil || experience.emotion != nil }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            fullScreenBackgroundPhoto
                .ignoresSafeArea()
            
            if allPhotos.count > 1 {
                VStack {
                    storyProgressBar
                        .padding(.top, 50)
                        .padding(.horizontal, 16)
                    Spacer()
                }
                .ignoresSafeArea()
            }
            
            VStack {
                Spacer()
                glassContentCard
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isShowingEdit = true
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
        .sheet(isPresented: $isShowingEdit) {
            AddExperienceView(editing: experience) { updated in
                experience = updated
                onSave(updated)
            }
        }
        .fullScreenCover(isPresented: $config.showFullScreenCover) {
            config.selectedItem = nil
        } content: {
            DetailPhotoView(config: $config, data: allPhotos) { item, isExpanded, _, _ in
                Image(uiImage: item.image)
                    .resizable()
                    .aspectRatio(contentMode: isExpanded ? .fit : .fill)
            } overlay: { _, _, dragOffset, dismiss in
                OverlayActionView(dragOffset: dragOffset, dismiss: dismiss)
            }
        }
        .onChange(of: config.selectedItem) { _, newValue in
            if let newValue, let index = allPhotos.firstIndex(of: newValue) {
                selectedImageIndex = index
            }
        }
        .onReceive(progressTimer) { _ in
            guard !allPhotos.isEmpty, !config.showFullScreenCover else { return }
            
            let step = 0.05 / displayDuration
            if progress + step >= 1.0 {
                progress = 0.0
                withAnimation(.easeInOut) {
                    selectedImageIndex = (selectedImageIndex + 1) % allPhotos.count
                }
            } else {
                progress += step
            }
        }
        .onChange(of: selectedImageIndex) { _, _ in
            progress = 0.0
        }
        .onDisappear {
            audioPlayer?.pause()
        }
    }
    
    private var storyProgressBar: some View {
        HStack(spacing: 4) {
            ForEach(0..<allPhotos.count, id: \.self) { index in
                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.35))
                        
                        Capsule()
                            .fill(Color.white)
                            .frame(width: barWidth(for: index, totalWidth: proxy.size.width))
                    }
                }
                .frame(height: 3)
            }
        }
    }
    
    private func barWidth(for index: Int, totalWidth: CGFloat) -> CGFloat {
        if index < selectedImageIndex {
            return totalWidth
        } else if index == selectedImageIndex {
            return totalWidth * CGFloat(progress)
        } else {
            return 0
        }
    }
    
    private var glassContentCard: some View {
        VStack(spacing: 16) {
            Text(experience.title.isEmpty ? "Sem título" : experience.title)
                .font(.custom("Georgia", size: 26))
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top)
            
            detailContent
        }
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 32, style: .continuous))
        .environment(\.colorScheme, .dark)
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.6), .white.opacity(0.1), .clear, .white.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: .black.opacity(0.25), radius: 15, x: 0, y: 10)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
    
    private var fullScreenBackgroundPhoto: some View {
        GeometryReader { proxy in
            if !allPhotos.isEmpty {
                TabView(selection: $selectedImageIndex) {
                    ForEach(Array(allPhotos.enumerated()), id: \.offset) { index, photo in
                        Image(uiImage: photo.image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: proxy.size.width, height: proxy.size.height)
                            .clipped()
                            .contentShape(Rectangle())
                            .onTapGesture {
                                // Clique simples para expandir a foto
                                config.selectedItem = photo
                                config.sourceLocation = proxy.frame(in: .global)
                                withoutAnimation { config.showFullScreenCover = true }
                            }
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            } else {
                Color(.systemGray4)
            }
        }
    }
    
    private var detailContent: some View {
        VStack(alignment: .leading, spacing: 18) {
            // Descrição
            if !experience.description.isEmpty {
                Text(experience.description)
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.9))
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            if hasMood && hasAudio {
                VStack(spacing: 8) {
                    TabView(selection: $selectedTab) {
                        moodTagsView
                            .tag(0)
                        
                        audioPlayerSection
                            .tag(1)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(height: 64)
                    
                    HStack(spacing: 6) {
                        Circle()
                            .fill(selectedTab == 0 ? Color.white : Color.white.opacity(0.3))
                            .frame(width: 6, height: 6)
                        
                        Circle()
                            .fill(selectedTab == 1 ? Color.white : Color.white.opacity(0.3))
                            .frame(width: 6, height: 6)
                    }
                    .animation(.easeInOut(duration: 0.2), value: selectedTab)
                }
            } else if hasMood {
                moodTagsView
                    .frame(height: 64)
            } else if hasAudio {
                audioPlayerSection
                    .frame(height: 64)
            }
            
            Divider()
                .overlay(Color.white.opacity(0.2))
            
            HStack(spacing: 16) {
                if experience.includeDate {
                    Label(experience.date.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                }
                Spacer()
                if experience.album != "Nenhum" {
                    Label(experience.album, systemImage: "square.stack")
                }
            }
            .font(.footnote)
            .foregroundStyle(.white.opacity(0.75))
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
    
    private var moodTagsView: some View {
        HStack(spacing: 12) {
            if let quality = experience.quality {
                detailTag(title: "Como foi?", imageName: quality.imageName, label: quality.label)
            }
            if let emotion = experience.emotion {
                detailTag(title: "Como se sentiu?", imageName: emotion.imageName, label: emotion.label)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
    }
    
    private var audioPlayerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(audioURLs, id: \.self) { url in
                audioPlayerRow(url: url)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
    }
    
    private func audioPlayerRow(url: URL) -> some View {
        HStack(spacing: 14) {
            Button {
                toggleAudioPlay(url: url)
            } label: {
                Image(systemName: isPlayingAudio && playingAudioURL == url ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Gravação de Áudio")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                Text(isPlayingAudio && playingAudioURL == url ? "Reproduzindo..." : "Toque para ouvir")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.75))
            }
            
            Spacer()
            
            Image(systemName: "waveform")
                .font(.title3)
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
    
    private func toggleAudioPlay(url: URL) {
        if isPlayingAudio && playingAudioURL == url {
            audioPlayer?.pause()
            isPlayingAudio = false
        } else {
            playingAudioURL = url
            audioPlayer = AVPlayer(url: url)
            audioPlayer?.play()
            isPlayingAudio = true
        }
    }
    
    private func detailTag(title: String, imageName: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.75))
            
            HStack(spacing: 6) {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                
                Text(label)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
    
    @ViewBuilder
    func OverlayActionView(dragOffset: CGSize, dismiss: @escaping () -> Void) -> some View {
        let interactiveOpacity: CGFloat = 1 - min(abs(dragOffset.height / 30), 1)
        
        VStack {
            HStack {
                Button(action: dismiss) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .frame(width: 20, height: 30)
                }
                .buttonStyle(.glass)
                Spacer(minLength: 0)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .compositingGroup()
        .opacity(interactiveOpacity)
    }
}

#Preview {
    NavigationStack {
        ExperienceDetailScreen(experience: .mock) { _ in }
            .environment(WallieViewModel())
    }
}
