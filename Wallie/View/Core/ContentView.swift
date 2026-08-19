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
                .tint(nil)
                .tabItem {
                    Label("Momentos", systemImage: "photo.fill.on.rectangle.fill")
                }
            MemoriesView()
                .tint(nil)
                .tabItem {
                    Label("Memórias", systemImage: "square.grid.3x3.square")
                }
            AlbunsView()
                .tint(nil)
                .tabItem {
                    Label("Álbuns", systemImage: "rectangle.stack")
                }
            
            CalendarView()
                .tint(nil)
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
