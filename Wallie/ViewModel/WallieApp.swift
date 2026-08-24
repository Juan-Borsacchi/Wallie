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
    let persistenceController = PersistenceController.shared
    
    @State private var viewmodel = WallieViewModel()
    @State private var showSplash = false
    
    // Captura o modelContext do container de forma limpa aqui na App struct
    @Environment(\.modelContext) private var modelContext
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    ContentView()
                        .environment(viewmodel)
                        .onAppear {
                            // Configura o DataManager assim que a ContentView aparece
                            DataManager.shared.setContext(modelContext)
                            viewmodel.refreshUI() // Atualiza os dados logo de cara
                        }
                } else {
                    VideoSplashScreen(showSplash: $showSplash)
                }
            }
        }
    }
}
