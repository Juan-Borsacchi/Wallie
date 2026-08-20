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
    
    @State private var displaySheet = false
    
    var body: some View {
        
        NavigationStack {
            ScrollView {
                VStack (alignment: .leading) {
                    HStack {
                        ToolBarViewsTitle(
                            title: "Álbuns",
                            subtitle: "Colecione mémorias",
                            onAdd: { displaySheet = true }
                        )
                    }
                    .padding(.bottom, 32)
                    
                    ForEach(viewmodel.albums) { album in
                        NavigationLink(value: album) {
                            
                            let allAlbumImages = getImagesForAlbum(albumName: album.name)
                            if allAlbumImages.isEmpty {
                                EmptyAlbum(emptyAlbumTitle: album.name)
                                
                            } else {
                                AlbumGroup(
                                    titleAlbum: album.name,
                                    images: Array(allAlbumImages.prefix(4)),
                                    totalCount: allAlbumImages.count)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
        }
        .navigationDestination(for: formAlbum.self) { album in
            SelectedAlbumView(album: album)
        }
        .sheet(isPresented: $displaySheet) {
            CreateAlbumView(onSave: { newAlbum in
                viewmodel.addNewAlbum(newAlbum)
            })
            .presentationDragIndicator(.visible)
            .presentationDetents([.large])
        }
    }
}

private func getImagesForAlbum(albumName: String) -> [UIImage] {
    let albumExperienceIDs = viewmodel.experiences
        .filter { $0.album == albumName }
        .map { $0.id }
    
    return viewmodel.allGallery
        .filter { albumExperienceIDs.contains($0.experienceID) }
        .compactMap { $0.image }
    
}
}

#Preview {
    AlbunsView()
        .environment(WallieViewModel())
}
