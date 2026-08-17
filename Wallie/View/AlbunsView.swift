//
//  AlbunsView.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 15/08/26.
//

import SwiftUI

struct AlbunsView: View {
    
    @Environment(\.managedObjectContext) var viewContext
    @Environment(WallieViewModel.self) var viewModel
    
    @State private var displaySheet = false
    @State private var albums: [formAlbum] = []
    
    var body: some View {
        
        NavigationStack {
            ScrollView {
                VStack (alignment: .leading) {
                    HStack {
                        
                        Title(title: "Álbuns", subtitle: "Colecione mémorias")
                        Spacer()
                        AddButton(displaySheet: $displaySheet)
                    }
                    .padding(.bottom, 27)
                    
                    ForEach(albums) { album in
                        NavigationLink(value: album) {
                            EmptyAlbum(emptyAlbumTitle: album.name)
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
                    albums.append(newAlbum)
                })
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.large])
            }
        }
    }
}

#Preview {
    AlbunsView()
        .environment(WallieViewModel())
}
