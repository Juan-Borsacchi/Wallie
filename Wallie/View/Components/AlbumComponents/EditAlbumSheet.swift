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
    
    @FocusState private var isInputFocused: Bool
    
    @State private var name: String
    @State private var category: String
    @State private var includeDate: Bool
    @State private var date: Date
    
    let categories = ["Nenhuma", "Amigos", "Viagem", "Trabalho", "Outros"]
    
    init(album: formAlbum, onSave: @escaping (formAlbum) -> Void) {
        self.album = album
        self.onSave = onSave
        
        _name = State(initialValue: album.name)
        _category = State(initialValue: album.category ?? "Nenhuma")
        _includeDate = State(initialValue: album.date != nil)
        _date = State(initialValue: album.date ?? Date())
    }
    
    var body: some View {
        
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Título", systemImage: "text.cursor")
                            .font(.callout)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                        
                        TextField("Dê um título para o álbum...", text: $name)
                            .focused($isInputFocused)
                    }
                    .padding(16)
                    .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Label("Categoria", systemImage: "folder")
                                .font(.callout)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            Picker("", selection: $category) {
                                ForEach(categories, id: \.self) { cat in
                                    Text(cat).tag(cat)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(.primary)
                        }
                    }
                    .padding(16)
                    .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    
                    DateSelectionRow(includeDate: $includeDate, date: $date)
                }
                .padding()
            }
            .background(Color(.secondarySystemBackground))
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
                        
                        updated.date = includeDate ? date : nil
                        
                        onSave(updated)
                        dismiss()
                    }
                }
            }
        }
    }
}
