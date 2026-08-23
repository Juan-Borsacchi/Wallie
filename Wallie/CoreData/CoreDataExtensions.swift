//
//  CoreDataExtensions.swift
//  Wallie
//

import CoreData
import UIKit
import SwiftUI

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
        
        if qualityVal != nil || emotionVal != nil {
            items.append(AddItem(type: .mood, content: .mood(quality: qualityVal, emotion: emotionVal)))
        }
        
        if let audioBytes = self.audio {
            if let audioArray = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: audioBytes) as? [Data] {
                for audioData in audioArray {
                    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("audio_\(UUID().uuidString).m4a")
                    try? audioData.write(to: tempURL)
                    items.append(AddItem(type: .audio, content: .audio(tempURL)))
                }
            } else {
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("audio_\(self.id?.uuidString ?? UUID().uuidString).m4a")
                try? audioBytes.write(to: tempURL)
                items.append(AddItem(type: .audio, content: .audio(tempURL)))
            }
        }
        
        if let photosBytes = self.photos,
           let dataArray = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: photosBytes) as? [Data] {
            
            let uiImages = dataArray.compactMap { UIImage(data: $0) }
            if !uiImages.isEmpty {
                items.append(AddItem(type: .photo, content: .images(uiImages)))
            }
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
            date: self.date,
            category: self.category
        )
    }
}
