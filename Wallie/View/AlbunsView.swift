//
//  AlbunsView.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 15/08/26.
//

import SwiftUI

struct AlbunsView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Environment(WallieViewModel.self) var viewmodel
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var displaySheet = false
    
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
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
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
                                        
                                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                            .font(.title3)
                                            .foregroundStyle(isSelected ? Color.accentColor : Color.white)
                                            .background(Circle().fill(isSelected ? Color.white : Color.black.opacity(0.3)).padding(2))
                                            .shadow(color: .black.opacity(0.2), radius: 2)
                                            .padding(8)
                                    }
                                    .scaleEffect(isEditingMode && isSelected ? 0.96 : 1.0)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
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
                    .padding(.bottom, 20)
                }
                .id(viewmodel.albums.map { "\($0.id)-\($0.name)" }.joined() + viewmodel.experiences.map { "\($0.id)-\($0.album)" }.joined())
            }
            .onAppear {
                DataManager.shared.loadData()
            }
            .toolbar {
                if isEditingMode {
                    ToolbarItemGroup(placement: .bottomBar) {
                        Spacer()
                        
                        Text(selectedAlbumIDs.isEmpty ? "Selecione Itens" : "\(selectedAlbumIDs.count) Selecionados")
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
                                .foregroundStyle(selectedAlbumIDs.isEmpty ? Color.secondary : Color.red)
                        }
                        .disabled(selectedAlbumIDs.isEmpty)
                    }
                }
            }
            .toolbar(isEditingMode ? .hidden : .visible, for: .tabBar)
            
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
    
    private func toggleAlbumSelection(for id: UUID) {
        if selectedAlbumIDs.contains(id) {
            selectedAlbumIDs.remove(id)
        } else {
            selectedAlbumIDs.insert(id)
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
