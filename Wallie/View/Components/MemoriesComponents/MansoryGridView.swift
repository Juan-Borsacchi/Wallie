//
//  MansoryGridView.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 18/08/26.
//

import SwiftUI

struct MasonryGridView<Data: RandomAccessCollection, GridItem: View, Detail: View, Overlay: View>: View where Data.Element: PhotoProtocol & Identifiable {

    var spacing: CGFloat = 12
    var columnsCount: Int = 2
    var data: Data
    var heightProvider: (Data.Element) -> CGFloat
    
    @ViewBuilder var gridItem: (Data.Element) -> GridItem
    @ViewBuilder var detail: (Data.Element, Bool, CGSize, @escaping () -> ()) -> Detail
    @ViewBuilder var overlay: (Data.Element?, Bool, CGSize, @escaping () -> ()) -> Overlay
    
    var onSelectionChanged: (Data.Element?) -> Void = { _ in }
    
    @State private var config: PhotoHeroEffectConfig<Data.Element> = .init()
    
    var body: some View {
        ScrollView(.vertical) {
            HStack(alignment: .top, spacing: spacing) {
                let columnsData = factoredData()
                
                ForEach(0..<columnsCount, id: \.self) { columnIndex in
                    LazyVStack(spacing: spacing) {
                        ForEach(columnsData[columnIndex]) { item in
                            Rectangle()
                                .foregroundStyle(.clear)
                                .overlay {
                                    GeometryReader { proxy in
                                        let rect = proxy.frame(in: .global)
                                        let updatedRect: CGRect? = config.selectedItem == item ? rect : nil
                                        
                                        gridItem(item)
                                            .opacity(config.selectedItem == item ? 0 : 1)
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                            .contentShape(.rect)
                                            .onTapGesture {
                                                config.selectedItem = item
                                                config.sourceLocation = rect
                                                
                                                withoutAnimation {
                                                    config.showFullScreenCover = true
                                                }
                                            }
                                            .onChange(of: updatedRect) { _, newValue in
                                                if let newValue {
                                                    config.sourceLocation = newValue
                                                }
                                            }
                                    }
                                }
                                .frame(height: heightProvider(item))
                                .clipped()
                                .contentShape(.rect)
                        }
                    }
                }
            }
            .padding(spacing)
            .scrollTargetLayout()
        }
        .scrollPosition($config.sourceScrollPosition)
        .fullScreenCover(isPresented: $config.showFullScreenCover) {
            config.selectedItem = nil
        } content: {
            DetailPhotoView(config: $config, data: data, detail: detail, overlay: overlay)
        }
        .onChange(of: config.selectedItem) { oldValue, newValue in
            if let newValue, oldValue != nil {
                config.sourceScrollPosition.scrollTo(id: newValue.id)
            }
            onSelectionChanged(newValue)
        }
    }
    
    private func factoredData() -> [[Data.Element]] {
        var colData = Array(repeating: [Data.Element](), count: columnsCount)
        var colHeights = Array(repeating: CGFloat(0), count: columnsCount)
        
        for item in data {
            let shortestColumn = colHeights.firstIndex(of: colHeights.min()!) ?? 0
            colData[shortestColumn].append(item)
            colHeights[shortestColumn] += heightProvider(item) + spacing
        }
        
        return colData
    }
    
    func onSelectionChanged(_ perform: @escaping (Data.Element?) -> Void) -> Self {
        var copy = self
        copy.onSelectionChanged = perform
        return copy
    }
}
