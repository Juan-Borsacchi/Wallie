//
//  AddListModel.swift
//  Wallie
//
//  Created by Juan Gabriel Borsacchi Marques on 14/08/26.
//

import SwiftUI

enum AddListModel: String, CaseIterable, Identifiable {
    case mood
    case photo
    case camera
    case audio
    
    var id: Self {self}
    
    var icon: String {
        switch self {
        case .mood: "face.smiling"
        case .photo: "photo"
        case .camera: "camera"
        case .audio: "waveform"
        
        }
    }
}

struct AddItem: Identifiable {
    let id = UUID()
    let type: AddListModel
    var conteudo: String = ""
}
