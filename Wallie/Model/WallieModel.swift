//
//  WallieModel.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 14/08/26.
//

import SwiftUI
import Foundation

struct FotoItem: Identifiable {
    let id: String
    let image: UIImage
}

struct Post: Identifiable {
    let id = UUID()
    let color: Color
    let height: CGFloat
}

struct formAlbum: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var date: Date?
    var category: String?
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
    
    var emoji: String {
        switch self {
        case .pessimo:   return "😖"
        case .ruim:      return "🙁"
        case .bom:       return "🙂"
        case .otimo:     return "😄"
        case .excelente: return "🤩"
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
    
    var emoji: String {
        switch self {
        case .triste:     return "😢"
        case .feliz:      return "😀"
        case .angustiado: return "😩"
        case .raiva:      return "😡"
        case .ansioso:    return "😰"
        case .calmo:      return "😌"
        case .surpreso:   return "😮"
        case .cansado:    return "🥱"
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
    
    var quality: QualityRating?
    var emotion: EmotionTag?
    
    var accentColor: Color?
    var backgroundGradient: [Color]?
    
    var extraItems: [AddItem]
    
    var isPlaceholder: Bool
    
    init(
        id: UUID = UUID(),
        images: [Data] = [],
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
    
    static let sky = LinearGradient(
        colors: [
            Color(red: 0.30, green: 0.52, blue: 0.78),
            Color(red: 0.80, green: 0.85, blue: 0.82),
            Color(red: 0.46, green: 0.56, blue: 0.34)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let pillGradient = LinearGradient(
        colors: [accentSoft, accentFront],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let colorSwatches: [Color] = [
        .gray, .cyan, .green, .yellow, .orange, .pink, .purple, .blue
    ]
    
    static let backgroundSwatches: [[Color]] = [
        [.purple, .pink],
        [.blue, .cyan],
        [.orange, .yellow, .pink],
        [.indigo, .purple, .pink],
        [.pink.opacity(0.6), .white]
    ]
}

import SwiftUI

protocol PhotoProtocol: Hashable {
    var id: String { get }
}

struct ItemGalery: Identifiable, PhotoProtocol {
    var id: String = UUID().uuidString
    var title: String
    var image: UIImage?
    var experienceID: UUID
}

struct PinGalleryItem: Identifiable, PhotoProtocol {
    var id: String = UUID().uuidString
    var title: String
    var imageName: String
    var customHeight: CGFloat
}

extension ItemGalery {
    var calculatedHeight: CGFloat {
        guard let image = image else { return 200 }
        
        let aspectRatio = image.size.height / image.size.width
        let screenWidth = UIScreen.main.bounds.width
        
        let columnsCount: CGFloat = 2
        let spacing: CGFloat = 12
        let horizontalPadding: CGFloat = 15 * 2
        
        let totalSpacing = (spacing * (columnsCount - 1)) + horizontalPadding
        let dynamicColumnWidth = (screenWidth - totalSpacing) / columnsCount
        
        return dynamicColumnWidth * aspectRatio
    }
}

var sampleExperienceID = UUID()
var sampleItems: [ItemGalery] = {
    (1...7).map { i in
        ItemGalery(
            title: "Title \(i)",
            image: UIImage(named: "foto\(i)"),
            experienceID: sampleExperienceID
        )
    }
}()
