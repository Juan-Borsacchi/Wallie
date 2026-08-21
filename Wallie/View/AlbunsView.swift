//
//  AlbunsView.swift
//  Wallie
//

import SwiftUI

struct AlbunsView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Environment(WallieViewModel.self) var viewmodel
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var displaySheet = false
    
    // MARK: - Estados de Seleção Múltipla
    @State private var isEditingMode = false
    @State private var selectedAlbumIDs: Set<UUID> = []
    @State private var isShowingDeleteAlert = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ToolBarViewsTitle(
                    title: "Álbuns",
                    subtitle: "Colecione memórias",
                    showEditButton: !viewmodel.albums.isEmpty,
                    isEditingMode: isEditingMode,
                    onAdd: { displaySheet = true },
                    onEditToggle: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            isEditingMode.toggle()
                            if !isEditingMode {
                                selectedAlbumIDs.removeAll()
                            }
                        }
                    }
                )
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(viewmodel.albums) { album in
                            let isSelected = selectedAlbumIDs.contains(album.id)
                            let albumExperiences = getExperiencesForAlbum(albumName: album.name)
                            let allAlbumImages = getImagesForAlbum(albumName: album.name)
                            
                            if isEditingMode {
                                Button {
                                    toggleAlbumSelection(for: album.id)
                                } label: {
                                    ZStack(alignment: .topTrailing) {
                                        albumCardContent(for: album, experiences: albumExperiences, images: allAlbumImages)
                                        
                                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle.fill")
                                            .font(.title2)
                                            .foregroundStyle(isSelected ? Color.verdeProjeto : Color.white.opacity(0.8))
                                            .background(Circle().fill(Color.black.opacity(0.25)))
                                            .padding(.top, 8)
                                            .padding(.trailing, 12)
                                            .transition(.scale.combined(with: .opacity))
                                    }
                                }
                                .buttonStyle(.plain)
                            } else {
                                NavigationLink(value: album) {
                                    albumCardContent(for: album, experiences: albumExperiences, images: allAlbumImages)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(16)
                    .padding(.bottom, isEditingMode ? 90 : 20)
                }
                // Garante a re-renderização imediata quando nomes de álbuns ou vínculos de experiências mudam
                .id(viewmodel.albums.map { "\($0.id)-\($0.name)" }.joined() + viewmodel.experiences.map { "\($0.id)-\($0.album)" }.joined())
            }
            .onAppear {
                // Atualiza o DataManager sempre que entrar ou voltar para a aba de Álbuns
                DataManager.shared.loadData()
            }
            .overlay(alignment: .bottom) {
                if isEditingMode && !selectedAlbumIDs.isEmpty {
                    HStack {
                        Text("\(selectedAlbumIDs.count) álbum(ns) selecionado(s)")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        Button(role: .destructive) {
                            isShowingDeleteAlert = true
                        } label: {
                            Label("Excluir", systemImage: "trash")
                                .font(.subheadline.weight(.semibold))
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.12), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .alert("Excluir Álbuns", isPresented: $isShowingDeleteAlert) {
                Button("Cancelar", role: .cancel) { }
                Button("Excluir (\(selectedAlbumIDs.count))", role: .destructive) {
                    deleteSelectedAlbums()
                }
            } message: {
                Text("Tem certeza que deseja apagar os \(selectedAlbumIDs.count) álbuns selecionados? As experiências associadas permanecerão salvas em suas memórias.")
            }
            .navigationDestination(for: formAlbum.self) { album in
                SelectedAlbumViews(album: album)
            }
            .sheet(isPresented: $displaySheet) {
                CreateAlbumView(existingAlbums: viewmodel.albums, onSave: { newAlbum in
                    viewmodel.addNewAlbum(newAlbum)
                })
                .presentationDragIndicator(.visible)
                .presentationDetents([.large])
            }
        }
    }
    
    // MARK: - Subviews
    @ViewBuilder
    private func albumCardContent(for album: formAlbum, experiences: [Experience], images: [UIImage]) -> some View {
        if experiences.isEmpty {
            EmptyAlbum(emptyAlbumTitle: album.name)
                .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            AlbumGroup(
                titleAlbum: album.name,
                images: Array(images.prefix(4)),
                totalCount: max(experiences.count, images.count)
            )
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    // MARK: - Métodos Auxiliares
    private func toggleAlbumSelection(for id: UUID) {
        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
            if selectedAlbumIDs.contains(id) {
                selectedAlbumIDs.remove(id)
            } else {
                selectedAlbumIDs.insert(id)
            }
        }
    }
    
    private func getExperiencesForAlbum(albumName: String) -> [Experience] {
        viewmodel.experiences.filter { $0.album == albumName }
    }
    
    private func deleteSelectedAlbums() {
        for id in selectedAlbumIDs {
            if let album = viewmodel.albums.first(where: { $0.id == id }) {
                viewmodel.deleteAlbum(album)
            }
        }
        selectedAlbumIDs.removeAll()
        withAnimation { isEditingMode = false }
    }
    
    private func getImagesForAlbum(albumName: String) -> [UIImage] {
        return viewmodel.experiences
            .filter { $0.album == albumName }
            .compactMap { exp in
                if let data = exp.images.first {
                    return UIImage(data: data)
                }
                return nil
            }
    }
}

#Preview {
    AlbunsView()
        .environment(WallieViewModel())
}
