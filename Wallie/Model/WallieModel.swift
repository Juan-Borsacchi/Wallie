//
//  WallieModel.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 14/08/26.
//

import SwiftUI
import Foundation
import UIKit

struct formAlbum: Identifiable, Hashable {
    var id: UUID = UUID()
    var name: String
    var date: Date?
    var category: String?
    
    init(id: UUID = UUID(), name: String, date: Date? = nil, category: String? = nil) {
        self.id = id
        self.name = name
        self.date = date
        self.category = category
    }
}

struct AddItem: Identifiable {
    let id = UUID()
    let type: AddListModel
    var content: AddItemContent?
    var caption: String = ""
}

struct ExperiencePhoto: Identifiable, PhotoProtocol, Hashable {
    let id: String
    let image: UIImage
}

enum AddListModel: String, CaseIterable, Identifiable {
    case mood
    case photo
    case camera
    case audio
    
    var id: Self { self }
    
    var icon: String {
        switch self {
        case .mood: return "face.smiling"
        case .photo: return "photo"
        case .camera: return "camera"
        case .audio: return "waveform"
        }
    }
}

enum ActiveSheet: Identifiable {
    case audioRecorder
    case photoPicker
    
    var id: Int {
        hashValue
    }
}

enum AddItemContent {
    case mood(quality: QualityRating?, emotion: EmotionTag?)
    case images([Data])
    case audio(URL)
}

enum DisplayMode {
    case stack
    case carousel
    case book
}

enum QualityRating: String, CaseIterable, Identifiable, Codable, Hashable {
    case pessimo, ruim, bom, otimo, excelente
    
    var id: String { rawValue }
    var label: String {
        switch self {
        case .pessimo:   return "Péssimo"
        case .ruim:      return "Ruim"
        case .bom:       return "Bom"
        case .otimo:     return "Ótimo"
        case .excelente: return "Excelente"
        }
    }
    
    var imageName: String {
        switch self {
        case .pessimo:   return "ZPessimo"
        case .ruim:      return "ZRuim"
        case .bom:       return "ZBom"
        case .otimo:     return "ZOtimo"
        case .excelente: return "ZExcelente"
        }
    }
}

enum EmotionTag: String, CaseIterable, Identifiable, Codable, Hashable {
    case triste, feliz, angustiado, raiva, ansioso, calmo, surpreso, cansado
    
    var id: String { rawValue }
    var label: String {
        switch self {
        case .triste:     return "Triste"
        case .feliz:      return "Feliz"
        case .angustiado: return "Angustiado"
        case .raiva:      return "Com raiva"
        case .ansioso:    return "Ansioso"
        case .calmo:      return "Calmo"
        case .surpreso:   return "Surpreso"
        case .cansado:    return "Cansado"
        }
    }
    
    var imageName: String {
        switch self {
        case .triste:     return "ETriste"
        case .feliz:      return "EFeliz"
        case .angustiado: return "EAngustiado"
        case .raiva:      return "ERaiva"
        case .ansioso:    return "EAnsioso"
        case .calmo:      return "ECalmo"
        case .surpreso:   return "ESurpreso"
        case .cansado:    return "ECansado"
        }
    }
}

struct Experience: Identifiable {
    let id: UUID
    var images: [Data]
    var title: String
    var description: String
    var includeDate: Bool
    var date: Date
    var album: String
    
    var uiCoverImage: UIImage? {
        guard let coverData = images.first else { return nil }
        return UIImage(data: coverData)
    }
    
    var quality: QualityRating?
    var emotion: EmotionTag?
    
    var accentColor: Color?
    var backgroundGradient: [Color]?
    
    var extraItems: [AddItem]
    var isPlaceholder: Bool
    
    init(
        id: UUID = UUID(),
        images: [Data] = [],
        uiCoverImage: UIImage? = nil,
        title: String = "",
        description: String = "",
        includeDate: Bool = false,
        date: Date = Date(),
        album: String = "Nenhum",
        quality: QualityRating? = nil,
        emotion: EmotionTag? = nil,
        accentColor: Color? = nil,
        backgroundGradient: [Color]? = nil,
        isPlaceholder: Bool = false,
        extraItems: [AddItem] = []
    ) {
        self.id = id
        self.images = images
        self.title = title
        self.description = description
        self.includeDate = includeDate
        self.date = date
        self.album = album
        self.quality = quality
        self.emotion = emotion
        self.accentColor = accentColor
        self.backgroundGradient = backgroundGradient
        self.isPlaceholder = isPlaceholder
        self.extraItems = extraItems
    }
    
    static let placeholder = Experience(
        isPlaceholder: true
    )
    
    static let mock = Experience(
        title: "Viagem Inesquecível",
        description: "Um dia incrível de sol e muita alegria com a família.",
        includeDate: true,
        date: Date(),
        album: "Viagem",
        quality: .excelente,
        emotion: .feliz
    )
}

enum MomentosPalette {
    static let accentFront = Color(red: 0.30, green: 0.36, blue: 0.12)
    static let accentSoft = Color(red: 0.62, green: 0.72, blue: 0.30)
}

protocol PhotoProtocol: Hashable {
    var id: String { get }
}

struct ItemGalery: Identifiable, PhotoProtocol {
    var id: String = UUID().uuidString
    var title: String
    var imageData: Data?
    var experienceID: UUID
    var aspectRatio: CGFloat = 1.0
    var uiImage: UIImage?
}

extension ItemGalery {
    var calculatedHeight: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        
        let columnsCount: CGFloat = 2
        let spacing: CGFloat = 12
        let horizontalPadding: CGFloat = 15 * 2
        
        let totalSpacing = (spacing * (columnsCount - 1)) + horizontalPadding
        let dynamicColumnWidth = (screenWidth - totalSpacing) / columnsCount
        
        return dynamicColumnWidth * aspectRatio
    }
}

extension UIImage {
    func generateThumbnail(maxDimension: CGFloat = 300) -> Data? {
        let aspectRatio = self.size.width / self.size.height
        let newSize: CGSize
        
        if self.size.width > self.size.height {
            newSize = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
        } else {
            newSize = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
        }
        
        guard let thumbnail = self.preparingThumbnail(of: newSize) else {
            return self.jpegData(compressionQuality: 0.5)
        }
        
        return thumbnail.jpegData(compressionQuality: 0.8)
    }
}
