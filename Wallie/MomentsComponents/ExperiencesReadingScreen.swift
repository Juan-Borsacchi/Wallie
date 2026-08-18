//
//  ExperiencesReadingScreen.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 17/08/26.
//

import SwiftUI

struct ExperiencesReadingScreen: View {
    @Binding var experiences: [Experience]
    
    @State private var selectedID: UUID?
    @State private var isShowingDetail = false
    
    var body: some View {
        ScrollView {
            if experiences.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "book")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                    Text("Nenhuma experiência ainda")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 80)
            } else {
                LazyVStack(spacing: 20) {
                    ForEach(experiences) { experience in
                        ExperienceCard(experience: experience)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedID = experience.id
                                isShowingDetail = true
                            }
                    }
                }
                .padding(20)
            }
        }
        .background(Color(.systemGray6))
        .navigationTitle("Suas experiências")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $isShowingDetail) {
            if let experience = experiences.first(where: { $0.id == selectedID }) {
                ExperienceDetailScreen(experience: experience) { updated in
                    if let index = experiences.firstIndex(where: { $0.id == updated.id }) {
                        experiences[index] = updated
                    }
                }
            }
        }
    }
}

struct ExperienceCard: View {
    let experience: Experience
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let data = experience.images.first, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipped()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(experience.title.isEmpty ? "Sem título" : experience.title)
                    .font(.headline)
                
                if !experience.description.isEmpty {
                    Text(experience.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                
                HStack(spacing: 12) {
                    if experience.includeDate {
                        Label(experience.date.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                    }
                    if experience.album != "Nenhum" {
                        Label(experience.album, systemImage: "square.stack")
                    }
                    if let quality = experience.quality {
                        Text(quality.emoji)
                    }
                    if let emotion = experience.emotion {
                        Text(emotion.emoji)
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding(16)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Previews
#Preview("Reading Screen") {
    NavigationStack {
        ExperiencesReadingScreen(experiences: .constant([.mock, .placeholder]))
    }
}

#Preview("List Card") {
    ExperienceCard(experience: .mock)
        .padding()
        .background(Color(.systemGroupedBackground))
}
