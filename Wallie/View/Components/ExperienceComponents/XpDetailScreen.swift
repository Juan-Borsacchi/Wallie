//
//  XpDetailScreen.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 17/08/26.
//

import SwiftUI

struct XpDetailScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(WallieViewModel.self) private var globalVM
    @State private var viewModel: ExperienceDetailViewModel
    
    init(
        experience: Experience,
        onSave: @escaping (Experience) -> Void,
        onDelete: ((Experience) -> Void)? = nil
    ) {
        _viewModel = State(
            initialValue: ExperienceDetailViewModel(
                experience: experience,
                onSave: onSave,
                onDelete: onDelete
            )
        )
    }
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        ZStack(alignment: .bottom) {
            backgroundPhotos
                .ignoresSafeArea()
            
            DetailProgressContainer(viewModel: viewModel)
            
            VStack {
                Spacer()
                XpGlassCard(title: viewModel.experience.title) {
                    cardContent
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        viewModel.isShowingEdit = true
                    } label: {
                        Label("Editar", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive) {
                        viewModel.isShowingDeleteAlert = true
                    } label: {
                        Label("Excluir", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(.white)
                }
                .menuStyle(.borderlessButton)
            }
        }
        .alert("Excluir Experiência", isPresented: $viewModel.isShowingDeleteAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Excluir", role: .destructive) {
                if let onDelete = viewModel.onDelete {
                    onDelete(viewModel.experience)
                } else {
                    globalVM.deleteExperience(viewModel.experience)
                }
                dismiss()
            }
        } message: {
            Text("Tem certeza que deseja excluir esta experiência? Esta ação não pode ser desfeita.")
        }
        .sheet(isPresented: $viewModel.isShowingEdit) {
            AddExperienceView(editing: viewModel.experience) { updated in
                viewModel.experience = updated
                viewModel.onSave(updated)
            }
        }
        .fullScreenCover(isPresented: $viewModel.config.showFullScreenCover) {
            viewModel.config.selectedItem = nil
        } content: {
            DetailPhotoView(config: $viewModel.config, data: viewModel.allPhotos) { item, isExpanded, _, _ in
                Image(uiImage: item.image)
                    .resizable()
                    .aspectRatio(contentMode: isExpanded ? .fit : .fill)
            } overlay: { _, _, dragOffset, dismiss in
                overlayActionView(dragOffset: dragOffset, dismiss: dismiss)
            }
        }
        .onChange(of: viewModel.selectedImageIndex) { _, _ in
            viewModel.progress = 0.0
        }
        .onDisappear {
            viewModel.stopAudio()
        }
    }
    
    private var backgroundPhotos: some View {
        GeometryReader { proxy in
            if !viewModel.allPhotos.isEmpty {
                TabView(selection: $viewModel.selectedImageIndex) {
                    ForEach(Array(viewModel.allPhotos.enumerated()), id: \.offset) { index, photo in
                        Image(uiImage: photo.image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: proxy.size.width, height: proxy.size.height)
                            .clipped()
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.config.selectedItem = photo
                                viewModel.config.sourceLocation = proxy.frame(in: .global)
                                withoutAnimation { viewModel.config.showFullScreenCover = true }
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
    
    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 18) {
            if !viewModel.experience.description.isEmpty {
                Text(viewModel.experience.description)
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.9))
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            interactiveSection
            
            Divider().overlay(Color.white.opacity(0.2))
            
            footerSection
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
    
    @ViewBuilder
    private var interactiveSection: some View {
        if viewModel.hasMood && viewModel.hasAudio {
            VStack(spacing: 8) {
                TabView(selection: $viewModel.selectedTab) {
                    moodSection.tag(0)
                    audioSection.tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 64)
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(viewModel.selectedTab == 0 ? Color.white : Color.white.opacity(0.3))
                        .frame(width: 6, height: 6)
                    Circle()
                        .fill(viewModel.selectedTab == 1 ? Color.white : Color.white.opacity(0.3))
                        .frame(width: 6, height: 6)
                }
                .animation(.easeInOut(duration: 0.2), value: viewModel.selectedTab)
            }
        } else if viewModel.hasMood {
            moodSection.frame(height: 64)
        } else if viewModel.hasAudio {
            audioSection.frame(height: 64)
        }
    }
    
    private var moodSection: some View {
        HStack(spacing: 12) {
            if let quality = viewModel.experience.quality {
                XpMoodTag(title: "Como foi?", imageName: quality.imageName, label: quality.label)
            }
            if let emotion = viewModel.experience.emotion {
                XpMoodTag(title: "Como se sentiu?", imageName: emotion.imageName, label: emotion.label)
            }
        }
    }
    
    private var audioSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(viewModel.audioURLs, id: \.self) { url in
                AudioPlayerRow(
                    url: url,
                    isPlaying: viewModel.isPlayingAudio && viewModel.playingAudioURL == url,
                    onTogglePlay: { viewModel.toggleAudioPlay(url: url) }
                )
            }
        }
    }
    
    private var footerSection: some View {
        HStack(spacing: 16) {
            if viewModel.experience.includeDate {
                Label(viewModel.experience.date.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
            }
            Spacer()
            if viewModel.experience.album != "Nenhum" {
                Label(viewModel.experience.album, systemImage: "square.stack")
            }
        }
        .font(.footnote)
        .foregroundStyle(.white.opacity(0.75))
    }
    
    @ViewBuilder
    private func overlayActionView(dragOffset: CGSize, dismiss: @escaping () -> Void) -> some View {
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

private struct DetailProgressContainer: View {
    var viewModel: ExperienceDetailViewModel
    
    var body: some View {
        if viewModel.allPhotos.count > 1 {
            VStack {
                XpStoryProgressBar(
                    count: viewModel.allPhotos.count,
                    selectedIndex: viewModel.selectedImageIndex,
                    progress: viewModel.progress
                )
                .padding(.top, 60)
                .padding(.horizontal, 16)
                Spacer()
            }
            .ignoresSafeArea()
        }
    }
}

#Preview {
    NavigationStack {
        XpDetailScreen(experience: .mock) { _ in }
            .environment(WallieViewModel())
    }
}
