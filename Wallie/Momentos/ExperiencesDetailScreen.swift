//
//  ExperiencesDetailScreen.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 17/08/26.
//

import SwiftUI

struct ExperienceDetailScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State var experience: Experience
    
    let onSave: (Experience) -> Void
    @State private var isShowingEdit = false
    @State private var selectedImageIndex = 0

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                photoGallery
                detailContent
            }
        }
        .background(Color(.systemGroupedBackground))
        .ignoresSafeArea(edges: .top)
        .navigationBarBackButtonHidden(true) // SwiftUI > 15 usa isto no lugar de .navigationBarHidden
        .overlay(alignment: .top) {
            topBar
                .padding(.horizontal, 20)
                .padding(.top, 8)
        }
        .sheet(isPresented: $isShowingEdit) {
            AddExperienceView(editing: experience) { updated in
                experience = updated
                onSave(updated)
            }
        }
    }

    private var photoGallery: some View {
        VStack(spacing: 10) {
            TabView(selection: $selectedImageIndex) {
                if experience.images.isEmpty {
                    Color(.systemGray4)
                        .frame(maxWidth: .infinity)
                        .tag(0)
                } else {
                    ForEach(Array(experience.images.enumerated()), id: \.offset) { index, data in
                        if let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .clipped()
                                .tag(index)
                        } else {
                            Color(.systemGray4).tag(index)
                        }
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 430)

            if experience.images.count > 1 {
                HStack(spacing: 6) {
                    ForEach(experience.images.indices, id: \.self) { index in
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
                .frame(maxWidth: .infinity, alignment: .leading)

            if !experience.description.isEmpty {
                Text(experience.description)
                    .font(.body)
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
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if experience.album != "Nenhum" {
                    Label(experience.album, systemImage: "square.stack")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(20)
        .padding(.bottom, 40)
    }

    private func detailTag(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(.ultraThinMaterial))
            }
            Spacer()
            Button { isShowingEdit = true } label: {
                Image(systemName: "pencil")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(.ultraThinMaterial))
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ExperienceDetailScreen(experience: .mock) { _ in }
}
