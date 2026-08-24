//
//  DataManager.swift
//  Wallie
//

import SwiftUI
import SwiftData

@Observable
@MainActor
class DataManager {
    static let shared = DataManager()
    
    var xperiences: [Xperience] = []
    var albums: [Album] = []
    
    private var modelContext: ModelContext?
    
    func setContext(_ context: ModelContext) {
        self.modelContext = context
        loadData()
    }
    
    func loadData() {
        guard let context = modelContext else { return }
        
        do {
            let xperienceDescriptor = FetchDescriptor<Xperience>(
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
            let albumDescriptor = FetchDescriptor<Album>(
                sortBy: [SortDescriptor(\.title, order: .forward)]
            )
            
            self.xperiences = try context.fetch(xperienceDescriptor)
            self.albums = try context.fetch(albumDescriptor)
        } catch {
            print("Erro ao carregar dados: \(error.localizedDescription)")
        }
    }
    
    func saveExperience(_ experienceUI: Experience) {
        guard let context = modelContext else { return }
        
        let targetID = experienceUI.id
        let descriptor = FetchDescriptor<Xperience>(
            predicate: #Predicate { $0.id == targetID }
        )
        
        let xperience: Xperience
        if let existing = try? context.fetch(descriptor).first {
            xperience = existing
        } else {
            xperience = Xperience()
            xperience.id = experienceUI.id
            context.insert(xperience)
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
        
        var allExtraImages: [UIImage] = []
        
        for item in experienceUI.extraItems {
            switch item.content {
            case .audio(let url):
                xperience.audio = try? Data(contentsOf: url)
                
            case .images(let uiImages):
                allExtraImages.append(contentsOf: uiImages)
                
            default:
                break
            }
        }
        
        if !allExtraImages.isEmpty {
            xperience.photos = try? NSKeyedArchiver.archivedData(withRootObject: allExtraImages, requiringSecureCoding: false)
        } else {
            xperience.photos = nil
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
            print("Erro ao salvar experiência: \(error.localizedDescription)")
        }
    }
    
    func saveAlbum(_ albumUI: formAlbum) {
        guard let context = modelContext else { return }
        
        let targetID = albumUI.id
        let descriptor = FetchDescriptor<Album>(
            predicate: #Predicate { $0.id == targetID }
        )
        
        if let existingAlbum = try? context.fetch(descriptor).first {
            existingAlbum.title = albumUI.name
            existingAlbum.category = albumUI.category
        } else {
            let album = Album()
            album.id = albumUI.id
            album.title = albumUI.name
            album.category = albumUI.category
            context.insert(album)
        }
        
        do {
            try context.save()
            loadData()
        } catch {
            print("Erro ao salvar/editar álbum: \(error.localizedDescription)")
        }
    }
    
    func updateAlbum(id: UUID, newName: String, newCategory: String) {
        guard let context = modelContext else { return }
        
        let descriptor = FetchDescriptor<Album>(
            predicate: #Predicate { $0.id == id }
        )
        
        do {
            if let albumToUpdate = try context.fetch(descriptor).first {
                albumToUpdate.title = newName
                albumToUpdate.category = newCategory
                
                try context.save()
                loadData()
            }
        } catch {
            print("Erro ao atualizar álbum: \(error.localizedDescription)")
        }
    }
    
    func updateExperience(id: UUID, newTitle: String, newCover: UIImage?) {
        guard let context = modelContext else { return }
        
        let descriptor = FetchDescriptor<Xperience>(
            predicate: #Predicate { $0.id == id }
        )
        
        do {
            if let experienceToUpdate = try context.fetch(descriptor).first {
                experienceToUpdate.title = newTitle
                
                if let cover = newCover, let imageData = cover.jpegData(compressionQuality: 0.8) {
                    experienceToUpdate.cover = imageData
                }
                
                try context.save()
                loadData()
            }
        } catch {
            print("Erro ao atualizar experiência: \(error.localizedDescription)")
        }
    }
    
    private func getOrCreateAlbum(withName name: String, in context: ModelContext) -> Album {
        let descriptor = FetchDescriptor<Album>(
            predicate: #Predicate { $0.title == name }
        )
        
        if let existingAlbum = try? context.fetch(descriptor).first {
            return existingAlbum
        }
        
        let newAlbum = Album()
        newAlbum.id = UUID()
        newAlbum.title = name
        context.insert(newAlbum)
        return newAlbum
    }
    
    func deleteAlbum(_ albumUI: formAlbum) {
        guard let context = modelContext else { return }
        
        let targetID = albumUI.id
        let descriptor = FetchDescriptor<Album>(
            predicate: #Predicate { $0.id == targetID }
        )
        
        do {
            if let albumToDelete = try context.fetch(descriptor).first {
                // Desvincula as experiências do álbum antes de deletar
                if let associatedExperiences = albumToDelete.xperiences {
                    for exp in associatedExperiences {
                        exp.album = nil
                    }
                }
                
                context.delete(albumToDelete)
                try context.save()
                loadData()
            }
        } catch {
            print("Erro ao deletar álbum: \(error.localizedDescription)")
        }
    }
    
    func deleteExperience(_ xperience: Xperience) {
        guard let context = modelContext else { return }
        
        context.delete(xperience)
        
        do {
            try context.save()
            loadData()
        } catch {
            print("Erro ao deletar experiência: \(error.localizedDescription)")
        }
    }
}
