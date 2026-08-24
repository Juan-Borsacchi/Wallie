//
//  WallieViewModel.swift
//  Wallie
//

import SwiftUI
import SwiftData

@Observable
class WallieViewModel {
    var displaySheet: Bool = false
    private let dataManager = DataManager.shared
    
    var experiences: [Experience] = []
    var albums: [formAlbum] = []
    var allGallery: [ItemGalery] = []
    
    init() {
        refreshUI()
    }
    
    func refreshUI() {
        dataManager.loadData()
        self.experiences = dataManager.xperiences.map { $0.toUIModel() }
        self.albums = dataManager.albums.map { $0.toUIModel() }
        self.allGallery = dataManager.xperiences.compactMap { xperience in
            guard let coverData = xperience.cover,
                  let uiImage = UIImage(data: coverData) else { return nil }
            
            let id = xperience.id
            
            return ItemGalery(
                id: id.uuidString,
                title: xperience.title,
                image: uiImage,
                experienceID: id
            )
        }
    }
    
    func addNewExperience(_ experience: Experience) {
        dataManager.saveExperience(experience)
        refreshUI()
    }
    
    func updateExperience(_ experience: Experience) {
        dataManager.saveExperience(experience)
        refreshUI()
    }

    func deleteExperience(_ experience: Experience) {

        if let itemToDelete = dataManager.xperiences.first(where: { $0.id == experience.id }) {
            dataManager.deleteExperience(itemToDelete)
            refreshUI()
        }
    }
    
    func addNewAlbum(_ album: formAlbum) {
        dataManager.saveAlbum(album)
        refreshUI()
    }
    
    func updateAlbum(_ album: formAlbum) {
        dataManager.saveAlbum(album)
        refreshUI()
    }
    
    func deleteAlbum(_ album: formAlbum) {
        dataManager.deleteAlbum(album)
        refreshUI()
    }
}
