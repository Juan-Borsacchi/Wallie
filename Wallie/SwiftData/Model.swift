//
//  Model.swift
//  Wallie
//
//  Created by Tais Akemi Kawaguti on 24/08/26.
//

import Foundation
import SwiftData

@Model
class Xperience {
    @Attribute(.unique) var id: UUID
    var title: String = ""
    var descriptions: String = ""
    var timestamp: Date = Date()
    var includeDate: Bool = true
    var sensation: String? = nil
    var feelings: String? = nil
    
    @Attribute(.externalStorage)
    var cover: Data? = nil
    
    @Attribute(.externalStorage)
    var coverThumbnail: Data? = nil
    
    @Attribute(.externalStorage)
    var photos: Data? = nil
    
    @Attribute(.externalStorage)
    var audio: Data? = nil
    
    var album: Album? = nil
    
    init(
        id: UUID = UUID(),
        title: String = "",
        descriptions: String = "",
        timestamp: Date = Date(),
        includeDate: Bool = true,
        sensation: String? = nil,
        feelings: String? = nil,
        cover: Data? = nil,
        photos: Data? = nil,
        audio: Data? = nil,
        album: Album? = nil
    ) {
        self.id = id
        self.title = title
        self.descriptions = descriptions
        self.timestamp = timestamp
        self.includeDate = includeDate
        self.sensation = sensation
        self.feelings = feelings
        self.cover = cover
        self.photos = photos
        self.audio = audio
        self.album = album
    }
}

@Model
class Album {
    @Attribute(.unique) var id: UUID
    var title: String
    var category: String?
    var date: Date = Date()
    
    @Relationship(deleteRule: .nullify, inverse: \Xperience.album)
    var xperiences: [Xperience]? = []
    
    init(
        id: UUID = UUID(),
        title: String = "",
        category: String = "",
        date: Date = Date(),
        xperiences: [Xperience]? = nil
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.xperiences = xperiences
        self.date = Date()
    }
}
