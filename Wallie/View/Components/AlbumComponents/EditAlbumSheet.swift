//
//  EditAlbumSheet.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 21/08/26.
//

import SwiftUI

struct EditAlbumSheet: View {
    @Environment(\.dismiss) var dismiss
    let album: formAlbum
    var onSave: (formAlbum) -> Void
    
    @State private var name: String = ""
    @State private var category: String = "Nenhuma"
    
    let categories = ["Nenhuma", "Amigos", "Viagem", "Trabalho", "Outros"]
    
    init(album: formAlbum, onSave: @escaping (formAlbum) -> Void) {
        self.album = album
        self.onSave = onSave
        _name = State(initialValue: album.name)
        _category = State(initialValue: album.category ?? "Nenhuma")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Título") {
                    TextField("Nome do Álbum", text: $name)
                }
                Section("Categoria") {
                    Picker("Categoria", selection: $category) {
                        ForEach(categories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                }
            }
            .navigationTitle("Editar Álbum")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        var updated = album
                        updated.name = name
                        updated.category = category == "Nenhuma" ? nil : category
                        onSave(updated)
                        dismiss()
                    }
                }
            }
        }
    }
}
