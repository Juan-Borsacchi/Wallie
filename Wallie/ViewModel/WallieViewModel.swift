//
//  WallieViewModel.swift
//  Wallie
//

import SwiftUI
import Observation
import Combine
import CoreData

@Observable
class WallieViewModel {
    var experiences: [Experience] = []
    var allGallery: [ItemGalery] = []
    var albums: [formAlbum] = []
    
    var displaySheet: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private let dataManager = DataManager.shared
    
    init() {
        dataManager.loadData()
        
        // Observa as mudanças do DataManager e atualiza a UI
        dataManager.$xperiences.sink { [weak self] fetchedXperiences in
            self?.experiences = fetchedXperiences.map { $0.toUIModel() }
            self?.updateGallery(from: fetchedXperiences)
        }.store(in: &cancellables)
        
        dataManager.$albums.sink { [weak self] fetchedAlbums in
            self?.albums = fetchedAlbums.map { $0.toUIModel() }
        }.store(in: &cancellables)
    }
    
    // MARK: - Experiências
    
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
    
    // MARK: - Álbuns
    
    func addNewAlbum(_ album: formAlbum) {
        dataManager.saveAlbum(album)
    }
    
    func deleteAlbum(_ album: formAlbum) {
        let context = PersistenceController.shared.container.viewContext
        let request: NSFetchRequest<Album> = Album.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", album.name)
        
        if let albumToDelete = try? context.fetch(request).first {
            // Desvincula as experiências associadas a este álbum antes de apagar
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
                print("Erro ao deletar álbum: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Galeria
    
    private func updateGallery(from dbExperiences: [Xperience]) {
        var newGallery: [ItemGalery] = []
        for xperience in dbExperiences {
            if let coverData = xperience.cover, let uiImage = UIImage(data: coverData) {
                let newItem = ItemGalery(
                    id: UUID().uuidString,
                    title: xperience.title ?? "",
                    image: uiImage,
                    experienceID: xperience.id ?? UUID()
                )
                newGallery.append(newItem)
            }
        }
        self.allGallery = newGallery
    }
}
