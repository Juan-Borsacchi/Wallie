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
    
    // MARK: - Estados de Seleção Múltipla e Ações em Lote
    @State private var isEditingMode = false
    @State private var selectedExperienceIDs: Set<UUID> = []
    @State private var isShowingDeleteAlert = false
    @State private var isShowingMoveAlbumSheet = false
    @State private var isShowingCreateAlbumSheet = false
    @State private var selectedTargetAlbum: String = "Nenhum"
    
    var recentExperiences: [Experience] {
        Array(viewmodel.experiences.sorted(by: { $0.date > $1.date }).prefix(5))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ToolBarViewsTitle(
                    title: "Memórias",
                    subtitle: "Explore seus momentos favoritos",
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
                        VStack(alignment: .leading, spacing: 20) {
                            
                            // Seção: A curto prazo
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
                                    HStack(spacing: 14) {
                                        ForEach(recentExperiences) { experience in
                                            let isSelected = selectedExperienceIDs.contains(experience.id)
                                            
                                            VStack(alignment: .leading, spacing: 8) {
                                                ZStack(alignment: .topTrailing) {
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
                                                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle.fill")
                                                            .font(.title3)
                                                            .foregroundStyle(isSelected ? Color.accentColor : .white.opacity(0.6))
                                                            .background(Circle().fill(Color.black.opacity(0.2)))
                                                            .padding(8)
                                                    }
                                                }
                                                
                                                Text(experience.title.isEmpty ? "Sem título" : experience.title)
                                                    .font(.caption.weight(.bold))
                                                    .lineLimit(1)
                                                    .foregroundStyle(.primary)
                                            }
                                            .frame(width: 135)
                                            .scaleEffect(isSelected ? 0.95 : 1.0)
                                            .animation(.easeInOut(duration: 0.2), value: isSelected)
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
                            }
                            
                            Divider()
                                .padding(.horizontal, 16)
                            
                            // Seção: Todos os Momentos
                            MemoriesTitles(
                                title: "Todos momentos",
                                subtitle: "Explore os momentos criados por você"
                            )
                            
                            MasonryGridView(
                                columnsCount: 2,
                                data: viewmodel.allGallery,
                                heightProvider: { $0.calculatedHeight }
                            ) { item in
                                let isSelected = selectedExperienceIDs.contains(item.experienceID)
                                
                                ZStack(alignment: .topTrailing) {
                                    ImageView(item, isExpanded: false)
                                    
                                    if isEditingMode {
                                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle.fill")
                                            .font(.title3)
                                            .foregroundStyle(isSelected ? Color.accentColor : .white.opacity(0.6))
                                            .background(Circle().fill(Color.black.opacity(0.2)))
                                            .padding(8)
                                    }
                                }
                                .scaleEffect(isSelected ? 0.96 : 1.0)
                                .animation(.easeInOut(duration: 0.2), value: isSelected)
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
                        .padding(.bottom, isEditingMode ? 90 : 20)
                    }
                }
            }
            .overlay(alignment: .bottom) {
                // Barra Flutuante com Ações de Mover ou Apagar os Itens Selecionados
                if isEditingMode && !selectedExperienceIDs.isEmpty {
                    HStack(spacing: 20) {
                        Text("\(selectedExperienceIDs.count) selecionado(s)")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        Button {
                            isShowingMoveAlbumSheet = true
                        } label: {
                            Label("Mover", systemImage: "folder.badge.plus")
                                .font(.subheadline.weight(.semibold))
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color.accentColor)
                        
                        Button(role: .destructive) {
                            isShowingDeleteAlert = true
                        } label: {
                            Image(systemName: "trash")
                                .font(.subheadline.weight(.semibold))
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
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
                    Form {
                        Section("Mover itens selecionados para:") {
                            Picker("Álbum", selection: $selectedTargetAlbum) {
                                ForEach(viewmodel.albums.map { $0.name }, id: \.self) { albumName in
                                    Text(albumName).tag(albumName)
                                }
                            }
                            .pickerStyle(.menu)
                            
                            Button {
                                // Fecha a folha de seleção para liberar a abertura do modal de novo álbum
                                isShowingMoveAlbumSheet = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                    isShowingCreateAlbumSheet = true
                                }
                            } label: {
                                Label("Criar novo álbum...", systemImage: "plus")
                            }
                        }
                    }
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
            }
            .sheet(isPresented: $isShowingCreateAlbumSheet) {
                CreateAlbumView(existingAlbums: viewmodel.albums) { newAlbum in
                    viewmodel.addNewAlbum(newAlbum)
                    selectedTargetAlbum = newAlbum.name
                    // Reabre a tela de mover com o novo álbum já selecionado
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        isShowingMoveAlbumSheet = true
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
    
    // MARK: - Funções Auxiliares
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
