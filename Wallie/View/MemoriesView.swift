//
//  WallieGalleryApp.swift
//  Wallie
//
//  Created by Tais Akemi Kawaguti on 14/08/26.
//

import SwiftUI

struct MemoriesView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Environment(WallieViewModel.self) var viewmodel
    
    @State private var isShowingAddExperience = false
    
    @State private var selectedMoments: Experience?
    @State private var isShowingDetail = false
    
    var body: some View {
        NavigationStack  {
            VStack() {
                HStack {
                    ToolBarMemoriesAlbuns(
                        title: "Memórias",
                        subtitle: nil,
                        onSearching: { print("Pesquisar") },
                        onAdd: { isShowingAddExperience = true }
                    )
                }
                .padding(16)
                
                if viewmodel.allGallery.isEmpty {
                    Spacer()
                    AlertMemories()
                    Spacer()
                    
                } else {
                    MemoriesTitles(title: "A curto prazo", subtitle: "Explore as fotos mais recentes")
                    Divider()
                    MemoriesTitles(title: "A longo prazo", subtitle: "Todas as fotos")
                    
                    MasonryGridView(
                        columnsCount: 2,
                        data: viewmodel.allGallery,
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
                    .safeAreaPadding(16)
                }
            }
            .sheet(isPresented: $isShowingAddExperience) {
                AddExperienceView { newExperience in
                    viewmodel.addNewExperience(newExperience)
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
            .cornerRadius(isExpanded ? 0 : 12)
            .clipped()
    }
    
    @available(iOS 26.0, *)
    @ViewBuilder
    func OverlayActionView(dragOffset: CGSize, dismiss: @escaping () -> ()) -> some View {
        let interactiveOpacity: CGFloat = 1 - min(abs(dragOffset.height / 30), 1)
        
        VStack {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .frame(width: 20, height: 30)
                }
                .buttonStyle(.glass)
                Spacer(minLength: 0)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .compositingGroup()
        .opacity(interactiveOpacity)
    }
    
    //    @ViewBuilder
    //    private func ActionButton(icon: String) -> some View {
    //        Button {} label: {
    //            Image(systemName: icon)
    //                .font(.title3)
    //                .padding(10)
    //        }
    //    }
}

#Preview {
    MemoriesView()
        .environment(WallieViewModel())
}
