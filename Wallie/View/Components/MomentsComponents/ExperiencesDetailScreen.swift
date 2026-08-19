//
//  ExperiencesDetailScreen.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 17/08/26.
//

import SwiftUI

struct ExperiencePhoto: Identifiable, PhotoProtocol, Hashable {
    let id: String
    let data: Data
    var uiImage: UIImage? { UIImage(data: data) }
}

struct ExperienceDetailScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State var experience: Experience
    let onSave: (Experience) -> Void
    
    @State private var isShowingEdit = false
    @State private var selectedImageIndex = 0
    @State private var config: PhotoHeroEffectConfig<ExperiencePhoto> = .init()

    private var mappedPhotos: [ExperiencePhoto] {
        experience.images.enumerated().map { index, data in
            ExperiencePhoto(id: "photo-\(index)", data: data)
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                photoGallery
                detailContent
            }
        }
        .background(Color(.systemGroupedBackground))
        .ignoresSafeArea(edges: .top)
        .navigationBarBackButtonHidden(true)
        .overlay(alignment: .top) {
            topBar.padding(.horizontal, 20).padding(.top, 8)
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
            DetailPhotoView(config: $config, data: mappedPhotos) { item, isExpanded, _, _ in
                if let uiImage = item.uiImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: isExpanded ? .fit : .fill)
                }
            } overlay: { _, _, dragOffset, dismiss in
                OverlayActionView(dragOffset: dragOffset, dismiss: dismiss)
            }
        }
        .onChange(of: config.selectedItem) { _, newValue in
            if let newValue, let index = mappedPhotos.firstIndex(of: newValue) {
                selectedImageIndex = index
            }
        }
    }

    private var photoGallery: some View {
        VStack(spacing: 10) {
            TabView(selection: $selectedImageIndex) {
                if mappedPhotos.isEmpty {
                    Color(.systemGray4).frame(maxWidth: .infinity).tag(0)
                } else {
                    ForEach(Array(mappedPhotos.enumerated()), id: \.offset) { index, item in
                        GeometryReader { proxy in
                            let rect = proxy.frame(in: .global)
                            
                            Rectangle()
                                .fill(Color.clear)
                                .overlay {
                                    if let uiImage = item.uiImage {
                                        Image(uiImage: uiImage).resizable().scaledToFill()
                                    } else {
                                        Color(.systemGray4)
                                    }
                                }
                                .clipped()
                                .opacity(config.selectedItem == item ? 0 : 1)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    config.selectedItem = item
                                    config.sourceLocation = rect
                                    withoutAnimation { config.showFullScreenCover = true }
                                }
                                .onChange(of: config.selectedItem == item ? rect : nil) { _, newValue in
                                    if let newValue { config.sourceLocation = newValue }
                                }
                        }
                        .tag(index)
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 430)

            if mappedPhotos.count > 1 {
                HStack(spacing: 6) {
                    ForEach(mappedPhotos.indices, id: \.self) { index in
                        Circle()
                            .fill(index == selectedImageIndex ? Color.primary : Color.secondary.opacity(0.35))
                            .frame(width: 6, height: 6)
                            .animation(.easeInOut(duration: 0.2), value: selectedImageIndex)
                    }
                }
            }
        }
        .background(Color(.systemGray5))
    }

    private var detailContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(experience.title.isEmpty ? "Sem título" : experience.title)
                .font(.custom("Georgia", size: 30))
                .foregroundStyle(.primary)

            if !experience.description.isEmpty {
                Text(experience.description)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if experience.quality != nil || experience.emotion != nil {
                HStack(spacing: 12) {
                    if let quality = experience.quality {
                        detailTag(title: "Como foi?", value: "\(quality.emoji) \(quality.label)")
                    }
                    if let emotion = experience.emotion {
                        detailTag(title: "Como se sentiu?", value: "\(emotion.emoji) \(emotion.label)")
                    }
                }
            }

            Divider()

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
            .foregroundStyle(.secondary)
        }
        .padding(20)
        .padding(.bottom, 40)
    }

    private func detailTag(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title).font(.caption.weight(.semibold)).foregroundStyle(.secondary)
            Text(value).font(.subheadline.weight(.semibold)).lineLimit(1).minimumScaleFactor(0.8)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var topBar: some View {
        HStack {
            topBarButton(icon: "chevron.left") { dismiss() }
            Spacer()
            topBarButton(icon: "pencil") { isShowingEdit = true }
        }
    }
    
    private func topBarButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .semibold))
                .buttonStyle(.glass)
                .tint(.white)
                .frame(width: 44, height: 44)
                .background(.black, in: Circle())
        }
    }
    
    @ViewBuilder
    func OverlayActionView(dragOffset: CGSize, dismiss: @escaping () -> ()) -> some View {
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
