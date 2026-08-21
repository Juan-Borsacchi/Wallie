//
//  SelectAlbumView.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 21/08/26.
//

import SwiftUI

struct SelectedAlbumViews: View {
    let album: formAlbum
    
    @Environment(\.dismiss) private var dismiss
    @Environment(WallieViewModel.self) var viewmodel
    
    @State private var isShowingAddExperience = false
    @State private var selectedMoments: Experience?
    @State private var isShowingDetail = false
    @State private var isShowingDeleteAlbumAlert = false
    @State private var isShowingEditAlbum = false
    
    var currentAlbum: formAlbum {
        viewmodel.albums.first(where: { $0.id == album.id }) ?? album
    }
    
    var albumGallery: [ItemGalery] {
        viewmodel.allGallery.filter { item in
            if let exp = viewmodel.experiences.first(where: { $0.id == item.experienceID }) {
                return exp.album == currentAlbum.name
            }
            return false
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Title(title: currentAlbum.name, subtitle: "")
                
                HStack {
                    if let category = currentAlbum.category {
                        TagCategory(nameCategory: category)
                    }
                    
                    if let date = currentAlbum.date {
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
            
            ToolbarSpacer(.fixed, placement: .topBarTrailing)
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isShowingAddExperience = true
                } label: {
                    Image(systemName: "plus")
                }.buttonStyle(.borderedProminent)
                    .tint(.corTitulo)
            }
        }
        .alert("Excluir Álbum", isPresented: $isShowingDeleteAlbumAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Excluir", role: .destructive) {
                viewmodel.deleteAlbum(currentAlbum)
                dismiss()
            }
        } message: {
            Text("Tem certeza que deseja excluir o álbum '\(currentAlbum.name)'?")
        }
        .sheet(isPresented: $isShowingAddExperience) {
            AddExperienceView(
                availableAlbums: viewmodel.albums.map { $0.name }
            ) { newExperience in
                var experienceAdd = newExperience
                experienceAdd.album = currentAlbum.name
                viewmodel.addNewExperience(experienceAdd)
            }
        }
        .sheet(isPresented: $isShowingEditAlbum) {
            EditAlbumSheet(album: currentAlbum) { updatedForm in
                viewmodel.updateAlbum(updatedForm)
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

extension SelectedAlbumViews {
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
