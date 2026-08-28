//
//  SwiftDataExtensions.swift
//  Wallie
//
//  Created by Tais Akemi Kawaguti on 24/08/26.
//

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
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("audio_\(self.id.uuidString).m4a")
            try? audioBytes.write(to: tempURL)
            items.append(AddItem(type: .audio, content: .audio(tempURL)))
        }
        
        if let photosBytes = self.photos,
           let decodedDataArray = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, NSData.self], from: photosBytes) as? [Data] {
            items.append(AddItem(type: .photo, content: .images(decodedDataArray)))
        }
        
        return Experience(
            id: self.id,
            images: imgData,
            title: self.title,
            description: self.descriptions,
            includeDate: true,
            date: self.timestamp,
            createdXp: self.createdXp,
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
            id: self.id,
            name: self.title,
            date: self.date,
            category: self.category
        )
    }
}
