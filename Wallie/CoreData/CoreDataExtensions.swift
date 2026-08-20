//
//  CoreDataExtensions.swift
//  Wallie
//
//  Created by Juan Gabriel Borsacchi Marques on 17/08/26.
//

import UIKit

extension Album {
    var experiencesArray: [Xperience] {
        let experiencesSet = xperiences as? Set<Xperience> ?? []
        return experiencesSet.sorted { ($0.timestamp ?? Date()) < ($1.timestamp ?? Date()) }
    }
}

extension Xperience {
    var uiImage: UIImage? {
        guard let data = self.cover else { return nil }
        return UIImage(data: data)
    }
}
