//
//  WallieViewModel.swift
//  Wallie
//

import SwiftUI
import Observation
import CoreData

@Observable
class WallieViewModel {
    var displaySheet: Bool = false
    private let dataManager = DataManager.shared
    
    var experiences: [Experience] {
        dataManager.xperiences.map { $0.toUIModel() }
    }
    
    var albums: [formAlbum] {
        dataManager.albums.map { $0.toUIModel() }
    }
    
    var allGallery: [ItemGalery] {
        dataManager.xperiences.compactMap { xperience in
            guard let coverData = xperience.cover,
                  let uiImage = UIImage(data: coverData),
                  let id = xperience.id else { return nil }
            
            return ItemGalery(
                id: id.uuidString,
                title: xperience.title ?? "",
                image: uiImage,
                experienceID: id
            )
        }
    }
    
    init() {
        dataManager.loadData()
    }
    
    func addNewExperience(_ experience: Experience) {
        dataManager.saveExperience(experience)
        dataManager.loadData()
    }
    
    func updateExperience(_ experience: Experience) {
        dataManager.saveExperience(experience)
        dataManager.loadData()
    }

    func deleteExperience(_ experience: Experience) {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<Xperience> = Xperience.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", experience.id as CVarArg)
        
        if let item = try? context.fetch(fetchRequest).first {
            dataManager.deleteExperience(item)
            dataManager.loadData()
        }
    }
    
    func addNewAlbum(_ album: formAlbum) {
        dataManager.saveAlbum(album)
        dataManager.loadData()
    }
    
    func updateAlbum(_ album: formAlbum) {
            dataManager.saveAlbum(album)
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
                dataManager.loadData()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
