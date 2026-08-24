//
//  MemoriesView.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 15/08/26.
//

import SwiftUI

struct MemoriesView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Environment(WallieViewModel.self) var viewmodel
    
    @State private var isShowingAddExperience = false
    @State private var selectedMoments: Experience?
    @State private var isShowingDetail = false
    
    @State private var isEditingMode = false
    @State private var selectedExperienceIDs: Set<UUID> = []
    @State private var isShowingDeleteAlert = false
    @State private var isShowingMoveAlbumSheet = false
    @State private var isShowingCreateAlbumSheet = false
    @State private var selectedTargetAlbum: String = "Nenhum"
    
    var recentExperiences: [Experience] {
        Array(viewmodel.recentMoments.sorted(by: { $0.date > $1.date }).prefix(5))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ToolBarViewsTitle(
                    title: "Memórias",
                    subtitle: "",
                    showEditButton: !viewmodel.allGallery.isEmpty,
                    isEditingMode: isEditingMode,
                    onAdd: { isShowingAddExperience = true },
                    onEditToggle: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isEditingMode.toggle()
                            if !isEditingMode {
                                selectedExperienceIDs.removeAll()
                            }
                        }
                    }
                )
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                
                if viewmodel.allGallery.isEmpty {
                    Spacer()
                    AlertMemories()
                    Spacer()
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 16) {
                            
                            if !recentExperiences.isEmpty {
                                MemoriesTitles(
                                    title: "A curto prazo",
                                    subtitle: "Seus momentos mais recentes"
                                )
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 14) {
                                        ForEach(recentExperiences) { experience in
                                            let isSelected = selectedExperienceIDs.contains(experience.id)
                                            
                                            VStack(alignment: .leading, spacing: 8) {
                                                ZStack(alignment: .bottomTrailing) {
                                                    if let data = experience.images.first, let uiImage = UIImage(data: data) {
                                                        Image(uiImage: uiImage)
                                                            .resizable()
                                                            .scaledToFill()
                                                            .frame(width: 135, height: 135)
                                                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                                    } else {
                                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                            .fill(Color(.systemGray5))
                                                            .frame(width: 135, height: 135)
                                                            .overlay(Image(systemName: "photo").foregroundStyle(.secondary))
                                                    }
                                                    
                                                    if isEditingMode {
                                                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                                            .font(.title3)
                                                            .foregroundStyle(isSelected ? Color.accentColor : Color.white)
                                                            .background(Circle().fill(isSelected ? Color.white : Color.black.opacity(0.3)).padding(2))
                                                            .shadow(color: .black.opacity(0.2), radius: 2)
                                                            .padding(8)
                                                    }
                                                }
                                                .scaleEffect(isEditingMode && isSelected ? 0.9 : 1.0)
                                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                                                
                                                Text(experience.title.isEmpty ? "Sem título" : experience.title)
                                                    .font(.caption.weight(.bold))
                                                    .lineLimit(1)
                                                    .foregroundStyle(.primary)
                                            }
                                            .frame(width: 135)
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                if isEditingMode {
                                                    toggleSelection(for: experience.id)
                                                } else {
                                                    self.selectedMoments = experience
                                                    self.isShowingDetail = true
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                }
                                
                                Divider()
                                    .padding(.horizontal, 16)
                            }
                            
                            MemoriesTitles(
                                title: "Todos momentos",
                                subtitle: "Explore os momentos criados por você"
                            )
                            
                            MasonryGrid(
                                columnsCount: 2,
                                data: viewmodel.allGallery,
                                heightProvider: { $0.calculatedHeight }
                            ) { item in
                                let isSelected = selectedExperienceIDs.contains(item.experienceID)
                                
                                ZStack(alignment: .bottomTrailing) {
                                    ImageView(item, isExpanded: false)
                                    
                                    if isEditingMode {
                                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                            .font(.title3)
                                            .foregroundStyle(isSelected ? Color.accentColor : Color.white)
                                            .background(Circle().fill(isSelected ? Color.white : Color.black.opacity(0.3)).padding(2))
                                            .shadow(color: .black.opacity(0.2), radius: 2)
                                            .padding(8)
                                    }
                                }
                                .scaleEffect(isEditingMode && isSelected ? 0.92 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if isEditingMode {
                                        toggleSelection(for: item.experienceID)
                                    } else {
                                        if let experienceOpen = viewmodel.experiences.first(where: { $0.id == item.experienceID }) {
                                            self.selectedMoments = experienceOpen
                                            self.isShowingDetail = true
                                        }
                                    }
                                }
                            } detail: { _, _, _, _ in
                                EmptyView()
                            } overlay: { _, _, _, _ in
                                EmptyView()
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.bottom, 16)
                        .animation(.easeInOut, value: recentExperiences.isEmpty)
                    }
                }
            }
            .toolbar {
                if isEditingMode {
                    ToolbarItemGroup(placement: .bottomBar) {
                        Button {
                            isShowingMoveAlbumSheet = true
                        } label: {
                            Image(systemName: "folder")
                                .font(.system(size: 18))
                        }
                        .disabled(selectedExperienceIDs.isEmpty)
                        
                        Spacer()
                        
                        Text(selectedExperienceIDs.isEmpty ? "Selecione Itens" : "\(selectedExperienceIDs.count) Selecionados")
                            .font(.footnote.weight(.semibold))
                            .fixedSize()
                            .contentTransition(.numericText())
                            .padding(.horizontal)
                        
                        Spacer()
                        
                        Button(role: .destructive) {
                            isShowingDeleteAlert = true
                        } label: {
                            Image(systemName: "trash")
                                .font(.system(size: 18))
                                .foregroundStyle(selectedExperienceIDs.isEmpty ? Color.secondary : Color.red)
                        }
                        .disabled(selectedExperienceIDs.isEmpty)
                    }
                }
            }
            .toolbar(isEditingMode ? .hidden : .visible, for: .tabBar)
            .alert("Excluir experiências", isPresented: $isShowingDeleteAlert) {
                Button("Cancelar", role: .cancel) { }
                Button("Excluir (\(selectedExperienceIDs.count))", role: .destructive) {
                    deleteSelectedExperiences()
                }
            } message: {
                Text("Tem certeza que deseja apagar os \(selectedExperienceIDs.count) itens selecionados?")
            }
            .sheet(isPresented: $isShowingMoveAlbumSheet) {
                NavigationStack {
                    ScrollView {
                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Label("Destino", systemImage: "folder")
                                        .font(.callout)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.primary)
                                    
                                    Spacer()
                                    
                                    Picker("", selection: $selectedTargetAlbum) {
                                        Text("Nenhum").tag("Nenhum" as String)
                                        ForEach(viewmodel.albums, id: \.id) { album in
                                            Text(album.name).tag(album.name as String)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .tint(.primary)
                                }
                            }
                            .padding(16)
                            .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            
                            Button {
                                isShowingMoveAlbumSheet = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                    isShowingCreateAlbumSheet = true
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "plus")
                                    Text("Criar novo álbum...")
                                }
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.accentColor)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(16)
                                .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            }
                        }
                        .padding()
                    }
                    .background(Color(.secondarySystemBackground))
                    .navigationTitle("Mover para Álbum")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancelar") { isShowingMoveAlbumSheet = false }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Mover") {
                                moveSelectedExperiencesToAlbum(selectedTargetAlbum)
                                isShowingMoveAlbumSheet = false
                            }
                        }
                    }
                }
                .presentationDragIndicator(.visible)
                .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $isShowingCreateAlbumSheet) {
                CreateAlbumView(existingAlbums: viewmodel.albums) { newAlbum in
                    viewmodel.addNewAlbum(newAlbum)
                    selectedTargetAlbum = newAlbum.name
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        isShowingMoveAlbumSheet = true
                    }
                }
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $isShowingAddExperience) {
                AddExperienceView { newExperience in
                    viewmodel.addNewExperience(newExperience)
                }
            }
            .navigationDestination(isPresented: $isShowingDetail) {
                if let experience = selectedMoments {
                    XpDetailScreen(
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
    
    private func toggleSelection(for id: UUID) {
        if selectedExperienceIDs.contains(id) {
            selectedExperienceIDs.remove(id)
        } else {
            selectedExperienceIDs.insert(id)
        }
    }
    
    private func deleteSelectedExperiences() {
        for id in selectedExperienceIDs {
            if let experience = viewmodel.experiences.first(where: { $0.id == id }) {
                viewmodel.deleteExperience(experience)
            }
        }
        selectedExperienceIDs.removeAll()
        withAnimation { isEditingMode = false }
    }
    
    private func moveSelectedExperiencesToAlbum(_ albumName: String) {
        for id in selectedExperienceIDs {
            if var experience = viewmodel.experiences.first(where: { $0.id == id }) {
                experience.album = albumName
                viewmodel.updateExperience(experience)
            }
        }
        selectedExperienceIDs.removeAll()
        withAnimation { isEditingMode = false }
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
            .cornerRadius(isExpanded ? 0 : 14)
            .clipped()
    }
}

#Preview {
    MemoriesView()
        .environment(WallieViewModel())
}
