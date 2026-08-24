//
//  CoreDataExtensions.swift
//  Wallie
//
//  Created by Juan Gabriel Borsacchi Marques on 14/08/26.
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
        var coverImg: UIImage? = nil

        if let coverData = cover {
            imgData.append(coverData)
            coverImg = UIImage(data: coverData)
        }
        
        var items: [AddItem] = []
        
        if qualityVal != nil || emotionVal != nil {
            items.append(AddItem(type: .mood, content: .mood(quality: qualityVal, emotion: emotionVal)))
        }
        
        if let audioBytes = self.audio {
            if let audioArray = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, NSData.self], from: audioBytes) as? [Data] {
                for (index, audioData) in audioArray.enumerated() {
                    let experienceID = self.id?.uuidString ?? "unknown"
                    let fileName = "audio_\(experienceID)_\(index).m4a"
                    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
                    
                    if !FileManager.default.fileExists(atPath: tempURL.path) {
                        try? audioData.write(to: tempURL)
                    }
                    items.append(AddItem(type: .audio, content: .audio(tempURL)))
                }
            } else {
                let experienceID = self.id?.uuidString ?? "unknown"
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("audio_\(experienceID).m4a")
                
                if !FileManager.default.fileExists(atPath: tempURL.path) {
                    try? audioBytes.write(to: tempURL)
                }
                items.append(AddItem(type: .audio, content: .audio(tempURL)))
            }
        }
        
        if let photosBytes = self.photos,
           let dataArray = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, NSData.self], from: photosBytes) as? [Data] {
            
            if !dataArray.isEmpty {
                items.append(AddItem(type: .photo, content: .images(dataArray)))
            }
        }
        
        return Experience(
            id: self.id ?? UUID(),
            images: imgData,
            uiCoverImage: coverImg,
            title: self.title ?? "Sem Título",
            description: self.descriptions ?? "",
            includeDate: self.includeDate,
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
