//
//  AddExperienceViewModel.swift
//  Wallie
//
//  Created by Juan Gabriel Borsacchi Marques on 20/08/26.
//


import SwiftUI
import PhotosUI
import Combine

@MainActor
final class AddExperienceViewModel: ObservableObject {
    
    let existingID: UUID?
    private let onSave: (Experience) -> Void
    
    @Published var coverImage: UIImage?
    @Published var title: String
    @Published var description: String
    @Published var includeDate: Bool
    @Published var date: Date
    @Published var album: String
    @Published var itensExtras: [AddItem]
    
    @Published var accentColor: Color?
    @Published var backgroundGradient: [Color]?
    
    @Published var showCoverPhotoPicker = false
    @Published var selectedCoverPhotoItems: [PhotosPickerItem] = [] {
        didSet { carregarCapa(selectedCoverPhotoItems) }
    }
    
    @Published var showCoverCamera = false
    @Published var capturedCoverImage: UIImage? {
        didSet {
            if let image = capturedCoverImage {
                withAnimation(.easeInOut(duration: 0.25)) { coverImage = image }
                capturedCoverImage = nil
            }
        }
    }
    
    @Published var showPhotoPicker = false
    @Published var selectedPhotoItems: [PhotosPickerItem] = [] {
        didSet { carregarFotosDosItens(selectedPhotoItems) }
    }
    
    @Published var showCamera = false
    @Published var capturedCameraImage: UIImage? {
        didSet {
            if let image = capturedCameraImage {
                withAnimation {
                    itensExtras.append(AddItem(type: .camera, content: .images([image])))
                }
                capturedCameraImage = nil
            }
        }
    }
    
    @Published var mostrarBarraDeItens = false
    
    let availableAlbums = ["Nenhum", "Viagem", "Família", "Trabalho"]
    
    var isSaveDisabled: Bool {
        coverImage == nil || title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    init(editing experience: Experience? = nil, onSave: @escaping (Experience) -> Void) {
        self.existingID = experience?.id
        self.onSave = onSave
        
        self.title = experience?.title ?? ""
        self.description = experience?.description ?? ""
        self.includeDate = experience?.includeDate ?? false
        self.date = experience?.date ?? Date()
        self.album = experience?.album ?? "Nenhum"
        self.accentColor = experience?.accentColor
        self.backgroundGradient = experience?.backgroundGradient
        self.itensExtras = experience?.extraItems ?? []
        
        if let data = experience?.images.first, let image = UIImage(data: data) {
            self.coverImage = image
        } else {
            self.coverImage = nil
        }
    }
        
    func adicionarItem(_ tipo: AddListModel) {
        withAnimation {
            switch tipo {
            case .mood:
                itensExtras.append(AddItem(type: .mood, content: .mood(quality: nil, emotion: nil)))
            case .photo:
                showPhotoPicker = true
            case .camera:
                showCamera = true
            case .audio:
                itensExtras.append(AddItem(type: .audio))
            }
        }
    }
    
    func salvarExperiencia() {
        var imagesData: [Data] = []
        if let coverImage, let coverData = coverImage.jpegData(compressionQuality: 0.9) {
            imagesData.append(coverData)
        }
        
        var quality: QualityRating?
        var emotion: EmotionTag?
        
        for item in itensExtras {
            if case let .mood(itemQuality, itemEmotion) = item.content {
                quality = itemQuality
                emotion = itemEmotion
                if quality != nil || emotion != nil { break }
            }
        }
        
        let experience = Experience(
            id: existingID ?? UUID(),
            images: imagesData,
            title: title,
            description: description,
            includeDate: includeDate,
            date: date,
            album: album,
            quality: quality,
            emotion: emotion,
            accentColor: accentColor,
            backgroundGradient: backgroundGradient,
            isPlaceholder: false,
            extraItems: itensExtras
        )
        
        onSave(experience)
    }
    
    private func carregarCapa(_ items: [PhotosPickerItem]) {
        guard let item = items.first else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                withAnimation(.easeInOut(duration: 0.25)) {
                    self.coverImage = image
                }
            }
            self.selectedCoverPhotoItems.removeAll()
        }
    }
    
    private func carregarFotosDosItens(_ items: [PhotosPickerItem]) {
        guard !items.isEmpty else { return }
        Task {
            var loadedImages: [UIImage] = []
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    loadedImages.append(image)
                }
            }
            if !loadedImages.isEmpty {
                withAnimation {
                    self.itensExtras.append(AddItem(type: .photo, content: .images(loadedImages)))
                }
            }
            self.selectedPhotoItems.removeAll()
        }
    }
}
