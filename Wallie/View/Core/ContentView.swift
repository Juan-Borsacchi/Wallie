//
//  ContentView.swift
//  Wallie
//
//  Created by Juan Gabriel Borsacchi Marques on 14/08/26.
//

import SwiftUI

struct ContentView: View {
    @Environment(WallieViewModel.self) var viewModel
 
    var body: some View {
        
        TabView {
            MomentsRootView()
                .tabItem {
                    Label("Momentos", systemImage: "photo.fill.on.rectangle.fill")
                }
            MosaicoView()
                .tabItem {
                    Label("Mosaico", systemImage: "square.grid.3x3.square")
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
        .tint(.green)
        .sheet(isPresented: Bindable(viewModel).displaySheet) {
            Text("sada")
            
        }
    }
    
}

#Preview {
    ContentView()
        .environment(WallieViewModel())
}
