//
//  SearchView.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 20/08/26.
//

import SwiftUI

struct SearchView: View {
    @Environment(WallieViewModel.self) var viewmodel
    @State private var query = ""
    
    var filterExperience: [Experience] {
        if query.isEmpty {
            return []
        }
        return viewmodel.experiences.filter { experience in
            experience.title.localizedCaseInsensitiveContains(query) ||
            experience.description.localizedCaseInsensitiveContains(query) ||
            experience.album.localizedCaseInsensitiveContains(query)
        }
    }
    
    
    var filterAlbums: [formAlbum] {
        if query.isEmpty {
            return []
        }
        return viewmodel.albums.filter { album in
            album.name.localizedCaseInsensitiveContains(query) ||
            (album.category ?? "")
                .localizedCaseInsensitiveContains(query)
        }
    }
    
    
    var body: some View {
        NavigationStack {
            Group {
                if query.isEmpty {
                    ContentUnavailableView(
                        "",
                        systemImage: "",
                        description: Text("Clique na barra abaixo e busque por momentos, álbuns ou categorias."))
                } else if filterExperience.isEmpty && filterAlbums.isEmpty {
                    ContentUnavailableView.search(text: query)
                } else {
                    List {
                        if !filterAlbums.isEmpty {
                            Section("Álbuns") {
                                ForEach(filterAlbums) { album in
                                    NavigationLink(destination: SelectedAlbumViews(album: album)) {
                                        HStack {
                                            Image(systemName: "rectangle.stack.fill")
                                                .foregroundStyle(.blue)
                                                .font(.title3)
                                            
                                            VStack(alignment: .leading) {
                                                Text(album.name)
                                                    .font(.headline)
                                                if let cat = album.category {
                                                    Text(cat)
                                                        .font(.caption)
                                                        .foregroundStyle(.secondary)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        if !filterExperience.isEmpty {
                            Section("Experiências") {
                                ForEach(filterExperience) { experience in
                                    NavigationLink(destination: ExperienceDetailScreen(
                                        experience: experience,
                                        onSave: { updated in
                                            viewmodel.updateExperience(updated)
                                        },
                                        onDelete: { deleted in
                                            viewmodel.deleteExperience(deleted)
                                        }
                                    )){
                                        HStack(spacing: 12) {
                                            if let data = experience.images.first, let uiImage = UIImage(data: data) {
                                                Image(uiImage: uiImage)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 50, height: 50)
                                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                            } else {
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(Color(.systemGray5))
                                                    .frame(width: 50, height: 50)
                                                    .overlay(Image(systemName: "photo")
                                                        .foregroundStyle(.secondary))
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(experience.title.isEmpty ? "Sem título" : experience.title)
                                                    .font(.headline)
                                                Text(experience.date.formatted(date: .abbreviated, time: .omitted))
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Pesquisar")
        }
        .searchable(text: $query, prompt: "Explore seus momentos e álbuns")
    }
}


#Preview {
    SearchView()
        .environment(WallieViewModel())
}
