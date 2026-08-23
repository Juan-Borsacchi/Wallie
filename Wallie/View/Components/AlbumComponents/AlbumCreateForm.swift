//
//  SheetAlbum.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 16/08/26.
//

import SwiftUI

struct AlbumCreateForm: View {
    @Binding var albumName: String
    @Binding var albumDate: Date
    @Binding var includeDate: Bool
    @Binding var selectedCategory: String
    
    let categories = ["Nenhuma", "Amigos", "Viagem", "Trabalho", "Outros"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                
                VStack(alignment: .leading, spacing: 8) {
                    Label("Título", systemImage: "text.cursor")
                        .font(.callout)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    
                    TextField("Nome do álbum...", text: $albumName)
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
                        
                        Picker("", selection: $selectedCategory) {
                            ForEach(categories, id: \.self) { category in
                                Text(category).tag(category)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(.primary)
                    }
                }
                .padding(16)
                .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label("Data", systemImage: "calendar")
                            .font(.callout)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        Toggle("", isOn: $includeDate.animation())
                            .labelsHidden()
                    }
                    
                    if includeDate {
                        Divider().padding(.vertical, 8)
                        DatePicker(
                            "Selecione a data",
                            selection: $albumDate,
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(.graphical)
                    }
                }
                .padding(16)
                .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .padding()
        }
        .background(Color(.secondarySystemBackground))
    }
}
