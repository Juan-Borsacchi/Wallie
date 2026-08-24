//
//  CreateAlbumView.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 15/08/26.
//

import SwiftUI

struct CreateAlbumView: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var viewContext
    
    var existingAlbums: [formAlbum] = []
    var onSave: (formAlbum) -> Void
    
    @State private var albumName: String = ""
    @State private var albumDate: Date = Date()
    @State private var includeDate: Bool = false
    @State private var selectedCategory: String = "Nenhuma"
    @State private var showAlertDuplicate: Bool = false
    
    var body: some View {
        NavigationStack {
            AlbumCreateForm(
                albumName: $albumName,
                albumDate: $albumDate,
                includeDate: $includeDate,
                selectedCategory: $selectedCategory
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                AlbumSheetToolBar(
                    cancelAction: {
                        dismiss()
                    },
                    confirmAction: {
                        saveAlbumProcess()
                    }
                )
            }
            .alert("Álbum existente", isPresented: $showAlertDuplicate) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Já existe um álbum com este nome. Por favor, escolha outro título.")
            }
        }
    }
    
    private func saveAlbumProcess() {
        let trimmedName = albumName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let finalName: String
        if trimmedName.isEmpty {
            finalName = generateUniqueDefaultName()
        } else {
            finalName = trimmedName
        }
        
        if existingAlbums.contains(where: { $0.name.lowercased() == finalName.lowercased() }) {
            showAlertDuplicate = true
            return
        }
        
        let category = selectedCategory == "Nenhuma" ? nil : selectedCategory
        let date = includeDate ? albumDate : nil
        let newAlbum = formAlbum(name: finalName, date: date, category: category)
        
        onSave(newAlbum)
        dismiss()
    }
    
    private func generateUniqueDefaultName() -> String {
        let baseName = "Novo Álbum"
        if !existingAlbums.contains(where: { $0.name.lowercased() == baseName.lowercased() }) {
            return baseName
        }
        
        var counter = 1
        while existingAlbums.contains(where: { $0.name.lowercased() == "\(baseName) \(counter)".lowercased() }) {
            counter += 1
        }
        return "\(baseName) \(counter)"
    }
}

#Preview {
    CreateAlbumView(existingAlbums: [], onSave: { album in
        print("Álbum salvo: \(album.name)")
    })
}
