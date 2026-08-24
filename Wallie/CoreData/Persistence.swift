//
//  Persistence.swift
//  Wallie
//
//  Created by Juan Gabriel Borsacchi Marques on 14/08/26.
//

import SwiftData
import Foundation

struct PersistenceController {
    static let shared = PersistenceController()
    
    let modelContainer: ModelContainer
    
    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let context = result.modelContainer.mainContext
        
        return result
    }()
    
    init(inMemory: Bool = false) {
        do {
            let schema = Schema([
                Xperience.self,
                Album.self
            ])
            let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
            modelContainer = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Falha ao criar o ModelContainer do SwiftData: \(error)")
        }
    }
}
