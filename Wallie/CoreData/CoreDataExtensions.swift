//
//  CoreDataExtensions.swift
//  Wallie
//
//  Created by Juan Gabriel Borsacchi Marques on 17/08/26.
//

import SwiftUI
import CoreData

extension Album: Identifiable {
    var experiencesArray: [Experience] {
        
    let experiencesSet = experiences as? Set<Experience> ?? []
        
    return experiencesSet.sorted {
        ($0.timestamp ?? Date()) < ($1.timestamp ?? Date())
        }
    }
}

extension Experience {
    var uiImage: UIImage? {
        
        guard let data = self.photos else { return nil }
        
        return UIImage(data: data)
    }
}
