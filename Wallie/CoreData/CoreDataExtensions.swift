//
//  CoreDataExtensions.swift
//  Wallie
//

import CoreData
import UIKit
import SwiftUI
import Combine

extension Xperience {
    func toUIModel() -> Experience {
        var qualityVal: QualityRating? = nil
        if let sens = sensation { qualityVal = QualityRating(rawValue: sens) }
        
        var emotionVal: EmotionTag? = nil
        if let feel = feelings { emotionVal = EmotionTag(rawValue: feel) }
        
        var imgData: [Data] = []
        if let coverData = cover {
            imgData.append(coverData)
        }
        
        var items: [AddItem] = []
        
        // 1. Reconstrói o item de Humor/Sentimento
        if qualityVal != nil || emotionVal != nil {
            items.append(AddItem(type: .mood, content: .mood(quality: qualityVal, emotion: emotionVal)))
        }
        
        // 2. Reconstrói o Áudio gravado se existir no CoreData
        if let audioBytes = self.audio {
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("audio_\(self.id?.uuidString ?? UUID().uuidString).m4a")
            try? audioBytes.write(to: tempURL)
            items.append(AddItem(type: .audio, content: .audio(tempURL)))
        }
        
        // 3. Reconstrói as Fotos extras se existirem
        if let photosBytes = self.photos,
           let uiImages = try? NSKeyedUnarchiver.unarchivedArrayOfObjects(ofClass: UIImage.self, from: photosBytes) {
            items.append(AddItem(type: .photo, content: .images(uiImages)))
        }
        
        return Experience(
            id: self.id ?? UUID(),
            images: imgData,
            title: self.title ?? "Sem Título",
            description: self.descriptions ?? "",
            includeDate: self.timestamp != nil,
            date: self.timestamp ?? Date(),
            album: self.album?.title ?? "Nenhum",
            quality: qualityVal,
            emotion: emotionVal,
            extraItems: items
        )
    }
}

extension Album {
    func toUIModel() -> formAlbum {
        return formAlbum(
            id: self.id ?? UUID(),
            name: self.title ?? "Sem Nome",
            date: nil,
            category: self.category
        )
    }
}
