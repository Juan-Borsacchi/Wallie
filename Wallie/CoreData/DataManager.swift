//
//  CoreDataExtensions.swift
//  Wallie
//
//  Created by Juan Gabriel Borsacchi Marques on 17/08/26.
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
            self.xperiences = try context.fetch(fetchXperiences)
            self.albums = try context.fetch(fetchAlbums)
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
        xperience.timestamp = experienceUI.date
        xperience.sensation = experienceUI.quality?.rawValue
        xperience.feelings = experienceUI.emotion?.rawValue
        
        if let coverData = experienceUI.images.first {
            xperience.cover = coverData
        }
        
        xperience.audio = nil
        xperience.photos = nil
        
        for item in experienceUI.extraItems {
            switch item.content {
            case .audio(let url):
                xperience.audio = try? Data(contentsOf: url)
                
            case .images(let uiImages):
                if !uiImages.isEmpty {
                    xperience.photos = try? NSKeyedArchiver.archivedData(withRootObject: uiImages, requiringSecureCoding: false)
                }
                
            default:
                break
            }
        }
        
        if experienceUI.album != "Nenhum" {
            xperience.album = getOrCreateAlbum(withName: experienceUI.album, in: context)
        } else {
            xperience.album = nil
        }
        
        do {
            try context.save()
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
            // Encontrou pelo ID: atualiza o álbum existente (incluindo o título novo!)
            album = existingAlbum
        } else {
            // Se realmente não tem ID no banco, aí sim criamos um novo
            album = Album(context: context)
            album.id = albumUI.id
        }
        
        // Atualiza os dados
        album.title = albumUI.name
        album.category = albumUI.category
        
        do {
            try context.save()
            loadData()
        } catch {
            print("Erro ao salvar/editar álbum: \(error.localizedDescription)")
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
                loadData()
            } else {
                print("Álbum não encontrado para atualização.")
            }
        } catch {
            print("Erro ao atualizar álbum: \(error.localizedDescription)")
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
        newAlbum.category = "Nenhuma"
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
                loadData()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
