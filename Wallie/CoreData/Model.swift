//
//  Model.swift
//  Wallie
//
//  Created by Tais Akemi Kawaguti on 24/08/26.
//

import Foundation
import SwiftData

@Model //AQUI ESTA BD
class Xperience {
    var id: UUID
    var title: String
    var descriptions: String
    var timestamp: Date
    var sensation: String?
    var feelings: String?
    var cover: Data?
    var audio: Data?
    var photos: Data?
    
    // Relacionamento com Album (muitos para um)
    var album: Album?
    
    init(
        id: UUID = UUID(),
        title: String = "",
        descriptions: String = "",
        timestamp: Date = Date(),
        sensation: String? = nil,
        feelings: String? = nil,
        cover: Data? = nil,
        audio: Data? = nil,
        photos: Data? = nil,
        album: Album? = nil
    ) {
        self.id = id
        self.title = title
        self.descriptions = descriptions
        self.timestamp = timestamp
        self.sensation = sensation
        self.feelings = feelings
        self.cover = cover
        self.audio = audio
        self.photos = photos
        self.album = album
    }
}

@Model
class Album {
    var id: UUID
    var title: String
    var category: String?
    
    @Relationship(deleteRule: .nullify, inverse: \Xperience.album)
    var xperiences: [Xperience]?
    
    init(
        id: UUID = UUID(),
        title: String = "",
        category: String? = nil,
        xperiences: [Xperience]? = nil
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.xperiences = xperiences
    }
}
