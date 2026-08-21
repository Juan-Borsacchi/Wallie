//
//  ContentView.swift
//  Wallie
//
//  Created by Juan Gabriel Borsacchi Marques on 14/08/26.
//

import SwiftUI

struct ContentView: View {
    @Environment(WallieViewModel.self) var viewmodel
 
    var body: some View {
        @Bindable var bindableViewmodel = viewmodel
        
        TabView {
            Tab("Momentos", systemImage: "photo.fill.on.rectangle.fill") {
                NavigationStack {
                    MomentsViews()
                }
                    .tint(nil)
            }
            
            Tab("Memórias", systemImage: "square.grid.3x3.square") {
                MemoriesView()
                    .tint(nil)
            }
            
            Tab("Álbuns", systemImage: "rectangle.stack") {
                AlbunsView()
                    .tint(nil)
            }
            
//     PRO FUTURO
//            Tab("Calendário", systemImage: "calendar") {
//                CalendarView()
//                    .tint(nil)
//            }
            
            Tab(role: .search) {
                SearchView()
            }
        }
        .tint(.verdeProjeto)
        .sheet(isPresented: $bindableViewmodel.displaySheet) {
            Text("Teste")
        }
    }
}

#Preview {
    ContentView()
        .environment(WallieViewModel())
}
