//
//  WallieApp.swift
//  Wallie
//
//  Created by Juan Gabriel Borsacchi Marques on 14/08/26.
//


import SwiftUI
import CoreData

@main
struct WallieApp: App {
    let persistenceController = PersistenceController.shared
    
    @State private var viewmodel = WallieViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environment(viewmodel)
        }
    }
}
