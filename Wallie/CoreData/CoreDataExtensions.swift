//
//  CoreDataExtensions.swift
//  Wallie
//
//  Created by Juan Gabriel Borsacchi Marques on 17/08/26.
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
            extraItems: []
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
