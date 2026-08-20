import CoreData
import UIKit
import SwiftUI
import Combine

class DataManager: ObservableObject {
    
    static let shared = DataManager()
    
    @Published var xperiences: [Xperience] = []
    @Published var albums: [Album] = []
    
    // MARK: - Core Data Operations
    
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
            print("Erro ao recuperar dados: \(error.localizedDescription)")
        }
    }
    
    func saveExperience(_ experienceUI: Experience) {
        let context = PersistenceController.shared.container.viewContext
        
        // Verifica se a experiência já existe (para Update)
        let fetchRequest: NSFetchRequest<Xperience> = Xperience.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", experienceUI.id as CVarArg)
        
        let xperience: Xperience
        if let existing = try? context.fetch(fetchRequest).first {
            xperience = existing
        } else {
            xperience = Xperience(context: context)
            xperience.id = experienceUI.id
        }
        
        // Mapeamento de UI -> Core Data
        xperience.title = experienceUI.title
        xperience.descriptions = experienceUI.description
        xperience.timestamp = experienceUI.date
        xperience.sensation = experienceUI.quality?.rawValue
        xperience.feelings = experienceUI.emotion?.rawValue
        
        if let coverData = experienceUI.images.first {
            xperience.cover = coverData
        }
        
        // Lógica de Relacionamento de Álbum
        if experienceUI.album != "Nenhum" {
            xperience.album = getOrCreateAlbum(withName: experienceUI.album, in: context)
        } else {
            xperience.album = nil
        }
        
        do {
            try context.save()
            print("Experiência salva com sucesso!")
            loadData()
        } catch {
            print("Erro ao salvar a experiência: \(error.localizedDescription)")
        }
    }
    
    func saveAlbum(_ albumUI: formAlbum) {
        let context = PersistenceController.shared.container.viewContext
        let album = getOrCreateAlbum(withName: albumUI.name, in: context)
        album.category = albumUI.category
        
        do {
            try context.save()
            loadData()
        } catch {
            print("Erro ao salvar álbum: \(error)")
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
            print("Erro ao deletar: \(error.localizedDescription)")
        }
    }
    // MARK: - Legacy Update (Para a UIViewController)
        
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
                    print("Experiência atualizada com sucesso pelo ID!")
                    loadData()
                } else {
                    print("Nenhuma experiência encontrada com o ID informado.")
                }
            } catch {
                print("Erro ao atualizar por ID: \(error.localizedDescription)")
            }
        }
}
