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
    
    var body: some View {
        NavigationStack  {
            
            VStack(spacing: 0) {
                ToolBarSelectedAlbum(
                    onSearching: { print("Pesquisar") },
                    onAdd: { isShowingAddExperience = true }
                )
                
                MemoriesTitles(title: "A longo prazo", subtitle: "Todas as fotos")
                
                MasonryGridView(
                    columnsCount: 2,
                    data: viewmodel.allGallery,
                    heightProvider: { $0.calculatedHeight }
                ) { item in
                    ImageView(item, isExpanded: false)
                } detail: { item, isExpanded, dragOffset, dismiss in
                    VStack {
                        if isExpanded { Spacer(minLength: 50) }
                        
                        ImageView(item, isExpanded: isExpanded)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        if isExpanded { Spacer(minLength: 50) }
                    }
                } overlay: { selectedItem, isExpanded, dragOffset, dismiss in
                    if #available(iOS 26.0, *) {
                        OverlayActionView(dragOffset: dragOffset, dismiss: dismiss)
                    }
                }
                .onSelectionChanged { item in
                    if let item { print(item) }
                }
                .safeAreaPadding(15)
            }
            .sheet(isPresented: $isShowingAddExperience) {
                AddExperienceView { newExperience in
                    viewmodel.addNewExperience(newExperience)
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
                
                Button {} label: {
                    Image(systemName: "ellipsis")
                        .font(.title3)
                        .frame(width: 20, height: 30)
                }
                .buttonStyle(.glass)
            }
            
            Spacer(minLength: 0)
            
            HStack {
                Button {} label: {
                    Image(systemName: "square.and.arrow.up.fill")
                        .font(.title3)
                        .frame(width: 20, height: 30)
                }
                .buttonStyle(.glass)
                
                HStack(spacing: 15) {
                    ActionButton(icon: "suit.heart")
                    ActionButton(icon: "info.circle")
                    ActionButton(icon: "slider.horizontal.3")
                }
            }
            .foregroundStyle(Color.primary)
            .padding(.horizontal, 10)
            .glassEffect(.regular.interactive(), in: .capsule)
            .frame(maxWidth: .infinity)
            
            Button {} label: {
                Image(systemName: "square.and.arrow.up.fill")
                    .font(.title3)
                    .frame(width: 20, height: 30)
            }
            .buttonStyle(.glass)
        }
        .padding(15)
        .compositingGroup()
        .opacity(interactiveOpacity)
    }
    
    @ViewBuilder
    private func ActionButton(icon: String) -> some View {
        Button {} label: {
            Image(systemName: icon)
                .font(.title3)
                .padding(10)
        }
    }
}

#Preview {
    MemoriesView()
        .environment(WallieViewModel())
}
