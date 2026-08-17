//
//  CreateAlbumView.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 15/08/26.
//

import SwiftUI

struct CreateAlbumView: View {
    
    @Environment(\.dismiss) var dismiss
    
    var onSave: (formAlbum) -> Void
    
    @State private var albumName: String = ""
    @State private var albumDate: Date = Date()
    @State private var includeDate: Bool = false
    @State private var selectedCategory: String = "Nenhuma"
    
    var body: some View {
        NavigationStack {
            CreateAlbumForm(
                albumName: $albumName,
                albumDate: $albumDate,
                includeDate: $includeDate,
                selectedCategory: $selectedCategory)
            
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolBarCreateSheetAlbum(
                    cancelAction: {
                        dismiss()
                    },
                    confirmAction: {
                        let category = selectedCategory == "Nenhuma" ? nil : selectedCategory
                        
                        let date = includeDate ? albumDate : nil
                        
                        let finalName = albumName.isEmpty ? "Novo Album" : albumName
                        
                        let newAlbum = formAlbum(name: finalName, date: date, category: category)
                        
                        onSave(newAlbum)
                        dismiss()
                    }
                )
            }
            
        }
        
    }
}

#Preview {
    CreateAlbumView(onSave: { album in
        print("Álbum salvo: \(album.name)")
    })
}
