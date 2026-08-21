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
            guard let coverData = xperience.cover, let uiImage = UIImage(data: coverData) else { return nil }
            return ItemGalery(
                id: xperience.id?.uuidString ?? UUID().uuidString,
                title: xperience.title ?? "",
                image: uiImage,
                experienceID: xperience.id ?? UUID()
            )
        }
    }
    
    init() {
        dataManager.loadData()
    }
    
    func addNewExperience(_ experience: Experience) {
        dataManager.saveExperience(experience)
    }
    
    func updateExperience(_ experience: Experience) {
        dataManager.saveExperience(experience)
    }

    func deleteExperience(_ experience: Experience) {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<Xperience> = Xperience.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", experience.id as CVarArg)
        
        if let item = try? context.fetch(fetchRequest).first {
            dataManager.deleteExperience(item)
        }
    }
    
    func addNewAlbum(_ album: formAlbum) {
        dataManager.saveAlbum(album)
    }
    
    func updateAlbum(_ album: formAlbum) {
            dataManager.saveAlbum(album)
        }
    
    func deleteAlbum(_ album: formAlbum) {
        let context = PersistenceController.shared.container.viewContext
        let request: NSFetchRequest<Album> = Album.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", album.name)
        
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
