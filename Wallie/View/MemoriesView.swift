//
//  MemoriesView.swift
//  Wallie
//

import SwiftUI

struct MemoriesView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Environment(WallieViewModel.self) var viewmodel
    
    @State private var isShowingAddExperience = false
    @State private var selectedMoments: Experience?
    @State private var isShowingDetail = false
    
    // Filtra e ordena as 5 experiências mais recentes
    var recentExperiences: [Experience] {
        Array(viewmodel.experiences.sorted(by: { $0.date > $1.date }).prefix(5))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    ToolBarViewsTitle(
                        title: "Memórias",
                        subtitle: nil,
                        onAdd: { isShowingAddExperience = true }
                    )
                }
                .padding(16)
                
                if viewmodel.allGallery.isEmpty {
                    Spacer()
                    AlertMemories()
                    Spacer()
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 16) {
                            
                            // MARK: - Seção A Curto Prazo (Experiências Recentes)
                            MemoriesTitles(
                                title: "A curto prazo",
                                subtitle: "Seus momentos mais recentes"
                            )
                            
                            if recentExperiences.isEmpty {
                                Text("Nenhuma experiência recente encontrada.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 16)
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(recentExperiences) { experience in
                                            VStack(alignment: .leading, spacing: 6) {
                                                if let data = experience.images.first, let uiImage = UIImage(data: data) {
                                                    Image(uiImage: uiImage)
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 130, height: 130)
                                                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                                } else {
                                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                        .fill(Color(.systemGray5))
                                                        .frame(width: 130, height: 130)
                                                        .overlay(Image(systemName: "photo").foregroundStyle(.secondary))
                                                }
                                                
                                                Text(experience.title.isEmpty ? "Sem título" : experience.title)
                                                    .font(.caption.weight(.semibold))
                                                    .lineLimit(1)
                                                    .foregroundStyle(.primary)
                                            }
                                            .frame(width: 130)
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                self.selectedMoments = experience
                                                self.isShowingDetail = true
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                }
                            }
                            
                            Divider()
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                            
                            // MARK: - Seção Todos os Momentos
                            MemoriesTitles(
                                title: "Todos momentos",
                                subtitle: "Explore os momentos criados por você"
                            )
                            
                            MasonryGridView(
                                columnsCount: 2,
                                data: viewmodel.allGallery,
                                heightProvider: { $0.calculatedHeight }
                            ) { item in
                                ImageView(item, isExpanded: false)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        if let experienceOpen = viewmodel.experiences.first(where: { $0.id == item.experienceID }) {
                                            self.selectedMoments = experienceOpen
                                            self.isShowingDetail = true
                                        }
                                    }
                            } detail: { _, _, _, _ in
                                EmptyView()
                            } overlay: { _, _, _, _ in
                                EmptyView()
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
            .sheet(isPresented: $isShowingAddExperience) {
                AddExperienceView(
                    availableAlbums: viewmodel.albums.map { $0.name }
                ) { newExperience in
                    viewmodel.addNewExperience(newExperience)
                }
            }
            .navigationDestination(isPresented: $isShowingDetail) {
                if let experience = selectedMoments {
                    ExperienceDetailScreen(
                        experience: experience,
                        onSave: { updated in
                            viewmodel.updateExperience(updated)
                        },
                        onDelete: { deleted in
                            viewmodel.deleteExperience(deleted)
                            isShowingDetail = false
                        }
                    )
                }
            }
        }
    }
}

extension MemoriesView {
    @ViewBuilder
    func ImageView(_ item: ItemGalery, isExpanded: Bool = false) -> some View {
        Rectangle()
            .foregroundStyle(.clear)
            .overlay {
                if let image = item.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: isExpanded ? .fit : .fill)
                }
            }
            .cornerRadius(isExpanded ? 0 : 12)
            .clipped()
    }
}

#Preview {
    MemoriesView()
        .environment(WallieViewModel())
}
