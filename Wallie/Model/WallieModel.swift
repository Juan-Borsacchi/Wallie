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
