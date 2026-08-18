//
//  WallieViewModel.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 16/08/26.
//

import SwiftUI
import Observation

@Observable
class WallieViewModel {
        var experiences: [Experience] = []
        var allGallery: [ItemGalery] = []
    
    var displaySheet: Bool = false
    
    func addNewExperience(_ experience: Experience) {
        experiences.insert(experience, at: 0)
        
        for imageData in experience.images {
            if let uiImage = UIImage(data: imageData) {
                let newItem = ItemGalery(id: UUID().uuidString, title: experience.title, image: uiImage)
                allGallery.insert(newItem, at: 0)
            }
        }
    }
}
