//
//  WallieApp.swift
//  Wallie
//
//  Created by Juan Gabriel Borsacchi Marques on 14/08/26.
//

import SwiftUI
import SwiftData

@main
struct WallieApp: App {
    @State private var viewmodel = WallieViewModel()
    @State private var showSplash = false
    
    var body: some Scene {
        WindowGroup {
            RootView(viewmodel: viewmodel, showSplash: $showSplash)
        }
        .modelContainer(for: [
            Xperience.self,
            Album.self
        ])
    }
}

struct RootView: View {
    let viewmodel: WallieViewModel
    @Binding var showSplash: Bool
    
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        ZStack {
            if showSplash {
                ContentView()
                    .environment(viewmodel)
                    .onAppear {
                        DataManager.shared.setContext(modelContext)
                        viewmodel.refreshUI()
                    }
            } else {
                VideoSplashScreen(showSplash: $showSplash)
            }
        }
    }
}
