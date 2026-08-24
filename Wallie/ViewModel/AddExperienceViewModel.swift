//
//  AddExperienceViewModel.swift
//  Wallie
//
//  Created by Juan Gabriel Borsacchi Marques on 20/08/26.
//

import SwiftUI
import PhotosUI
import Observation

enum ExperienceSheetType: Identifiable {
    case coverCamera
    case extraCamera
    case createAlbum
    
    var id: Self { self }
}

@MainActor
@Observable
final class AddExperienceViewModel {
    let existingID: UUID?
    private let onSave: (Experience) -> Void
    
    var coverImage: UIImage?
    var title: String
    var description: String
    var includeDate: Bool
    var date: Date
    var album: String
    var itensExtras: [AddItem]
    
    var accentColor: Color?
    var backgroundGradient: [Color]?
    
    var showCoverPhotoPicker = false
    var selectedCoverPhotoItems: [PhotosPickerItem] = [] {
        didSet { carregarCapa(selectedCoverPhotoItems) }
    }
    
    var activeSheet: ExperienceSheetType?
    
    var capturedCoverImage: UIImage? {
        didSet {
            if let image = capturedCoverImage {
                withAnimation(.easeInOut(duration: 0.25)) { coverImage = image }
                capturedCoverImage = nil
            }
        }
    }
    
    var showPhotoPicker = false
    var selectedPhotoItems: [PhotosPickerItem] = [] {
        didSet { carregarFotosDosItens(selectedPhotoItems) }
    }
    
    var capturedCameraImage: UIImage? {
        didSet {
            if let image = capturedCameraImage {
                withAnimation {
                    if let data = image.jpegData(compressionQuality: 0.8) {
                        if let index = itensExtras.firstIndex(where: { $0.type == .photo }),
                           case .images(var existingData) = itensExtras[index].content {
                            existingData.append(data)
                            itensExtras[index].content = .images(existingData)
                        } else {
                            itensExtras.append(AddItem(type: .photo, content: .images([data])))
                        }
                    }
                }
                capturedCameraImage = nil
            }
        }
    }
    
    var isSaveDisabled: Bool {
        coverImage == nil || title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    init(
        editing experience: Experience? = nil,
        onSave: @escaping (Experience) -> Void
    ) {
        self.existingID = experience?.id
        self.onSave = onSave
        
        self.title = experience?.title ?? ""
        self.description = experience?.description ?? ""
        self.includeDate = experience?.includeDate ?? false
        self.date = experience?.date ?? Date()
        self.album = experience?.album ?? "Nenhum"
        self.accentColor = experience?.accentColor
        self.backgroundGradient = experience?.backgroundGradient
        
        if let exp = experience, exp.extraItems.isEmpty && (exp.quality != nil || exp.emotion != nil) {
            self.itensExtras = [AddItem(type: .mood, content: .mood(quality: exp.quality, emotion: exp.emotion))]
        } else {
            self.itensExtras = experience?.extraItems ?? []
        }
        
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
                if !itensExtras.contains(where: { $0.type == .mood }) {
                    itensExtras.append(AddItem(type: .mood, content: .mood(quality: nil, emotion: nil)))
                }
            case .photo:
                showPhotoPicker = true
            case .camera:
                if !itensExtras.contains(where: { $0.type == .camera }) {
                    itensExtras.append(AddItem(type: .camera))
                }
            case .audio:
                if !itensExtras.contains(where: { $0.type == .audio }) {
                    itensExtras.append(AddItem(type: .audio))
                }
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
            let processedData = await Task.detached {
                var tempLoadedData: [Data] = []
                
                for item in items {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data),
                       let compressedData = uiImage.jpegData(compressionQuality: 0.8) {
                        tempLoadedData.append(compressedData)
                    }
                }
                return tempLoadedData
            }
                .value
            
            if !processedData.isEmpty {
                withAnimation {
                    if let index = self.itensExtras.firstIndex(where: { $0.type == .photo }),
                       case .images(var existingData) = self.itensExtras[index].content {
                        existingData.append(contentsOf: processedData)
                        self.itensExtras[index].content = .images(existingData)
                    } else {
                        self.itensExtras.append(AddItem(type: .photo, content: .images(processedData)))
                    }
                }
            }
            
            self.selectedPhotoItems.removeAll()
        }
    }
}
