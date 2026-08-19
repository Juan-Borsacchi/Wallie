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
            MomentsRootView()
                .tabItem {
                    Label("Momentos", systemImage: "photo.fill.on.rectangle.fill")
                }
            MemoriesView()
                .tabItem {
                    Label("Memórias", systemImage: "square.grid.3x3.square")
                }
            AlbunsView()
                .tabItem {
                    Label("Álbuns", systemImage: "rectangle.stack")
                }
            
            CalendarView()
                .tabItem {
                    Label("Calendário", systemImage: "calendar")
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
