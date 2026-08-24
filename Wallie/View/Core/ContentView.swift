//
//  ContentView.swift
//  Wallie
//
//  Created by Juan Gabriel Borsacchi Marques on 14/08/26.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(WallieViewModel.self) var viewmodel
    @State private var selectedTab: Int = 0
    
    var body: some View {
        @Bindable var bindableViewmodel = viewmodel
        
        TabView(selection: $selectedTab) {
            Tab("Momentos", systemImage: "photo.fill.on.rectangle.fill", value: 0) {
                NavigationStack {
                    MomentsView()
                }
                .tint(nil)
            }
            
            Tab("Memórias", systemImage: "square.grid.3x3.square", value: 1) {
                MemoriesView()
                    .tint(nil)
            }
            
            Tab("Álbuns", systemImage: "rectangle.stack", value: 2) {
                AlbunsView()
                    .tint(nil)
            }
            
            Tab(value: 3, role: .search) {
                SearchView()
            }
        }
        .tint(colorScheme == .dark ? .verdeProjeto : .verdeEscuro)
        .onChange(of: selectedTab) { _, _ in
            DataManager.shared.loadData()
        }
        .sheet(isPresented: $bindableViewmodel.displaySheet) {
            Text("Teste")
        }
    }
}

#Preview {
    ContentView()
        .environment(WallieViewModel())
}
