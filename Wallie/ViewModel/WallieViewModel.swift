//
//  WallieViewModel.swift
//  Wallie
//
//  Created by Juan Gabriel Borsacchi Marques on 14/08/26.
//

import SwiftUI
import Observation
import CoreData

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
        guard let expireRecent = calendar.date(byAdding: .second, value: -60, to: currentTime) else {
            return experiences
        }
        return experiences.filter { $0.date >= expireRecent }
    }
    
    init() {
        refreshUI()
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.currentTime = Date()
        }
    }
    
    func refreshUI() {
        dataManager.loadData()
        self.experiences = dataManager.xperiences.map { $0.toUIModel() }
        self.albums = dataManager.albums.map { $0.toUIModel() }
        
        self.allGallery = dataManager.xperiences.compactMap { xperience in
            guard let coverData = xperience.cover,
                  let id = xperience.id else { return nil }
            
            return ItemGalery(
                id: id.uuidString,
                title: xperience.title ?? "",
                imageData: coverData,
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
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<Xperience> = Xperience.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", experience.id as CVarArg)
        
        if let item = try? context.fetch(fetchRequest).first {
            dataManager.deleteExperience(item)
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
        let context = PersistenceController.shared.container.viewContext
        let request: NSFetchRequest<Album> = Album.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", album.id as CVarArg)
        
        if let albumToDelete = try? context.fetch(request).first {
            if let associatedExperiences = albumToDelete.xperiences as? Set<Xperience> {
                for exp in associatedExperiences {
                    exp.album = nil
                }
            }
            context.delete(albumToDelete)
            
            do {
                try context.save()
                refreshUI()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
