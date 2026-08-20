//
//  SelectedAlbumView.swift
//  Wallie
//

import SwiftUI

struct SelectedAlbumView: View {
    let album: formAlbum
    
    @Environment(\.dismiss) private var dismiss
    @Environment(WallieViewModel.self) var viewmodel
    
    @State private var isShowingAddExperience = false
    @State private var selectedMoments: Experience?
    @State private var isShowingDetail = false
    @State private var isShowingDeleteAlbumAlert = false
    @State private var isShowingEditAlbum = false
    
    var albumGallery: [ItemGalery] {
        viewmodel.allGallery.filter { item in
            if let exp = viewmodel.experiences.first(where: { $0.id == item.experienceID }) {
                return exp.album == album.name
            }
            return false
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Title(title: album.name, subtitle: "")
                
                HStack {
                    if let category = album.category {
                        TagCategory(nameCategory: category)
                    }
                    
                    if let date = album.date {
                        TagDate(dateSelected: date)
                    }
                }
                .padding(.bottom, 16)
                
                MasonryGridView(
                    columnsCount: 2,
                    data: albumGallery,
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
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // MARK: - Botão 1: Menu de Opções do Álbum (com 'ellipsis' SF Symbol)
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        isShowingEditAlbum = true
                    } label: {
                        Label("Editar Álbum", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive) {
                        isShowingDeleteAlbumAlert = true
                    } label: {
                        Label("Excluir Álbum", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 18, weight: .semibold))
                }
            }
            
            // MARK: - Botão 2: Adicionar Experiência (Separado em outro ToolbarItem)
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isShowingAddExperience = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .alert("Excluir Álbum", isPresented: $isShowingDeleteAlbumAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Excluir", role: .destructive) {
                viewmodel.deleteAlbum(album)
                dismiss()
            }
        } message: {
            Text("Tem certeza que deseja excluir o álbum '\(album.name)'?")
        }
        .sheet(isPresented: $isShowingAddExperience) {
            AddExperienceView(
                availableAlbums: viewmodel.albums.map { $0.name }
            ) { newExperience in
                var experienceAdd = newExperience
                experienceAdd.album = album.name
                viewmodel.addNewExperience(experienceAdd)
            }
        }
        .sheet(isPresented: $isShowingEditAlbum) {
            EditAlbumSheetView(album: album) { updatedAlbum in
                viewmodel.addNewAlbum(updatedAlbum)
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
                        isShowingDetail = false // Fecha a tela de detalhes após apagar
                    }
                )
            }
        }
    }
}

extension SelectedAlbumView {
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

// MARK: - Modal de Edição do Álbum
struct EditAlbumSheetView: View {
    @Environment(\.dismiss) var dismiss
    let album: formAlbum
    var onSave: (formAlbum) -> Void
    
    @State private var name: String = ""
    @State private var category: String = "Nenhuma"
    
    let categories = ["Nenhuma", "Amigos", "Viagem", "Trabalho", "Outros"]
    
    init(album: formAlbum, onSave: @escaping (formAlbum) -> Void) {
        self.album = album
        self.onSave = onSave
        _name = State(initialValue: album.name)
        _category = State(initialValue: album.category ?? "Nenhuma")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Título") {
                    TextField("Nome do Álbum", text: $name)
                }
                Section("Categoria") {
                    Picker("Categoria", selection: $category) {
                        ForEach(categories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                }
            }
            .navigationTitle("Editar Álbum")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        var updated = album
                        updated.name = name
                        updated.category = category == "Nenhuma" ? nil : category
                        onSave(updated)
                        dismiss()
                    }
                }
            }
        }
    }
}
