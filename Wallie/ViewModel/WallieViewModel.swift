import SwiftUI
import Observation
import Combine

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
    
    func addNewExperience(_ experience: Experience) {
        dataManager.saveExperience(experience)
    }
    
    func addNewAlbum(_ album: formAlbum) {
        dataManager.saveAlbum(album)
    }
    
    private func updateGallery(from dbExperiences: [Xperience]) {
        var newGallery: [ItemGalery] = []
        for xperience in dbExperiences {
            if let coverData = xperience.cover, let uiImage = UIImage(data: coverData) {
                let newItem = ItemGalery(id: UUID().uuidString, title: xperience.title ?? "", image: uiImage, experienceID: xperience.id ?? UUID())
                newGallery.append(newItem)
            }
        }
        self.allGallery = newGallery
    }
}
