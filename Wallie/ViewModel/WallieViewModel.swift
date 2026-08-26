//
//  WallieViewModel.swift
//  Wallie
//
//  Created by Juan Gabriel Borsacchi Marques on 14/08/26.
//

import SwiftUI
import Observation

@MainActor
@Observable
class WallieViewModel {
    var displaySheet: Bool = false
    private let dataManager = DataManager.shared
    
    var experiences: [Experience] = []
    var albums: [formAlbum] = []
    var allGallery: [ItemGalery] = []
    
    var currentTime = Date()
    
    var recentMoments: [Experience] {
        let calendar = Calendar.current
        guard let expireRecent = calendar.date(byAdding: .day, value: -7, to: currentTime) else {
            return experiences
        }
        return experiences.filter { $0.date >= expireRecent }
    }
    
    var sortedRecentExperiences: [Experience] {
        Array(recentMoments.sorted(by: { $0.date > $1.date }).prefix(5))
    }
    
    init() {
        refreshUI()
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.currentTime = Date()
            }
        }
    }
    
    func refreshUI() {
        dataManager.loadData()
        self.experiences = dataManager.xperiences.map { $0.toUIModel() }
        self.albums = dataManager.albums.map { $0.toUIModel() }
        
        self.allGallery = dataManager.xperiences.compactMap { xperience in
            
            let targetData = xperience.coverThumbnail ?? xperience.cover
            guard let coverData = xperience.cover,
                  let decodedImg = UIImage(data: coverData) else { return nil }
            
            let id = xperience.id
            let ratio = decodedImg.size.height / decodedImg.size.width
            
            return ItemGalery(
                id: id.uuidString,
                title: xperience.title,
                imageData: coverData,
                experienceID: id,
                aspectRatio: ratio,
                uiImage: decodedImg
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
