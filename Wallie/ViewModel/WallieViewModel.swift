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
        // Encontra o objeto Xperience correspondente na lista gerenciada pelo DataManager
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
        // Usa o ModelContext do PersistenceController para buscar e deletar o álbum de forma limpa
        let context = PersistenceController.shared.modelContainer.mainContext
        let targetID = album.id
        let descriptor = FetchDescriptor<Album>(
            predicate: #Predicate { $0.id == targetID }
        )
        
        if let albumToDelete = try? context.fetch(descriptor).first {
            // Remove o vínculo das experiências associadas (caso a regra não seja cascade)
            if let associatedExperiences = albumToDelete.xperiences {
                for exp in associatedExperiences {
                    exp.album = nil
                }
            }
            
            context.delete(albumToDelete)
            
            do {
                try context.save()
                refreshUI()
            } catch {
                print("Erro ao deletar álbum: \(error.localizedDescription)")
            }
        }
    }
}
