//
//  SelectedAlbumView.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 16/08/26.
//

import SwiftUI

struct SelectedAlbumView: View {
    let album: formAlbum
    
    @Environment(WallieViewModel.self) var viewmodel
    
    @State private var isShowingAddExperience = false
    @State private var selectedMoments: Experience?
    @State private var isShowingDetail = false
    
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
                            if let experienceOpen = viewmodel.experiences.first(where: { exp in
                                return exp.id == item.experienceID
                            }) {
                                self.selectedMoments = experienceOpen
                                self.isShowingDetail = true
                            }
                        }
                } detail: { item, isExpanded, dragOffset, dismiss in
                    EmptyView()
                } overlay: { item, isExpanded, dragOffset, dismiss in
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    isShowingAddExperience = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $isShowingAddExperience) {
            AddExperienceView { newExperience in
                var experienceAdd = newExperience
                experienceAdd.album = album.name
                viewmodel.addNewExperience(experienceAdd)
            }
        }
        .navigationDestination(isPresented: $isShowingDetail) {
            if let experience = selectedMoments {
                ExperienceDetailScreen(experience: experience, onSave: { updated in
                    if let index = viewmodel.experiences.firstIndex(where: { $0.id == updated.id }) {
                        viewmodel.experiences[index] = updated
                    }
                })
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

#Preview {
    SelectedAlbumView(album: formAlbum(name: "Viagem pro Chile", date: Date(), category: "Viagem"))
        .environment(WallieViewModel())
}
