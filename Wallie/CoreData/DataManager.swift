//
//  DataManager.swift
//  Wallie
//
//  Created by Juan Gabriel Borsacchi Marques on 14/08/26.
//

import CoreData
import UIKit
import SwiftUI
import Observation

@Observable
class DataManager {
    static let shared = DataManager()
    
    var xperiences: [Xperience] = []
    var albums: [Album] = []
    
    func loadData() {
        let context = PersistenceController.shared.container.viewContext
        
        let fetchXperiences: NSFetchRequest<Xperience> = Xperience.fetchRequest()
        fetchXperiences.sortDescriptors = [NSSortDescriptor(keyPath: \Xperience.timestamp, ascending: false)]
        
        let fetchAlbums: NSFetchRequest<Album> = Album.fetchRequest()
        fetchAlbums.sortDescriptors = [NSSortDescriptor(keyPath: \Album.title, ascending: true)]
        
        do {
            let fetchedXperiences = try context.fetch(fetchXperiences)
            let fetchedAlbums = try context.fetch(fetchAlbums)
            
            self.xperiences = Array(fetchedXperiences)
            self.albums = Array(fetchedAlbums)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func saveExperience(_ experienceUI: Experience) {
        let context = PersistenceController.shared.container.viewContext
        
        let fetchRequest: NSFetchRequest<Xperience> = Xperience.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", experienceUI.id as CVarArg)
        
        let xperience: Xperience
        if let existing = try? context.fetch(fetchRequest).first {
            xperience = existing
        } else {
            xperience = Xperience(context: context)
            xperience.id = experienceUI.id
        }
        
        xperience.title = experienceUI.title
        xperience.descriptions = experienceUI.description
        xperience.timestamp = experienceUI.includeDate ? experienceUI.date : nil
        xperience.sensation = experienceUI.quality?.rawValue
        xperience.feelings = experienceUI.emotion?.rawValue
        
        if let coverData = experienceUI.images.first {
            xperience.cover = coverData
        }
        
        var allExtraImagesData: [Data] = []
        var allAudioData: [Data] = []
        
        for item in experienceUI.extraItems {
            switch item.content {
            case .audio(let url):
                if let audioData = try? Data(contentsOf: url) {
                    allAudioData.append(audioData)
                }
            case .images(let uiImages):
                let datas = uiImages.compactMap { $0.jpegData(compressionQuality: 0.8) }
                allExtraImagesData.append(contentsOf: datas)
            default:
                break
            }
        }
        
        if !allExtraImagesData.isEmpty {
            xperience.photos = try? NSKeyedArchiver.archivedData(withRootObject: allExtraImagesData, requiringSecureCoding: true)
        } else {
            xperience.photos = nil
        }
        
        if !allAudioData.isEmpty {
            xperience.audio = try? NSKeyedArchiver.archivedData(withRootObject: allAudioData, requiringSecureCoding: true)
        } else {
            xperience.audio = nil
        }
        
        if experienceUI.album != "Nenhum" {
            xperience.album = getOrCreateAlbum(withName: experienceUI.album, in: context)
        } else {
            xperience.album = nil
        }
        
        do {
            try context.save()
            context.refreshAllObjects()
            loadData()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func saveAlbum(_ albumUI: formAlbum) {
        let context = PersistenceController.shared.container.viewContext
        
        let request: NSFetchRequest<Album> = Album.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", albumUI.id as CVarArg)
        
        let album: Album
        if let existingAlbum = try? context.fetch(request).first {
            let oldName = existingAlbum.title
            
            existingAlbum.title = albumUI.name
            existingAlbum.category = albumUI.category
            existingAlbum.date = albumUI.date
            
            if let oldName = oldName, oldName != albumUI.name,
               let associatedExperiences = existingAlbum.xperiences as? Set<Xperience> {
                for exp in associatedExperiences {
                    exp.album = existingAlbum
                }
            }
        } else {
            album = Album(context: context)
            album.id = albumUI.id
            album.title = albumUI.name
            album.category = albumUI.category
            album.date = albumUI.date
        }
        
        do {
            try context.save()
            context.refreshAllObjects()
            loadData()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateAlbum(id: UUID, newName: String, newCategory: String) {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<Album> = Album.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            if let albumToUpdate = try context.fetch(fetchRequest).first {
                albumToUpdate.title = newName
                albumToUpdate.category = newCategory
                
                try context.save()
                context.refreshAllObjects()
                loadData()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func getOrCreateAlbum(withName name: String, in context: NSManagedObjectContext) -> Album {
        let request: NSFetchRequest<Album> = Album.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", name)
        
        if let existingAlbum = try? context.fetch(request).first {
            return existingAlbum
        }
        
        let newAlbum = Album(context: context)
        newAlbum.id = UUID()
        newAlbum.title = name
        return newAlbum
    }
    
    func deleteExperience(_ xperience: Xperience) {
        let context = PersistenceController.shared.container.viewContext
        context.delete(xperience)
        
        do {
            try context.save()
            loadData()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateExperience(id: UUID, newTitle: String, newCover: UIImage?) {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<Xperience> = Xperience.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            if let experienceToUpdate = try context.fetch(fetchRequest).first {
                experienceToUpdate.title = newTitle
                
                if let cover = newCover, let imageData = cover.jpegData(compressionQuality: 0.8) {
                    experienceToUpdate.cover = imageData
                }
                
                try context.save()
                context.refreshAllObjects()
                loadData()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
