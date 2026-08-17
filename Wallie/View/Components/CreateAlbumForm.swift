//
//  SheetAlbum.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 16/08/26.
//

import SwiftUI

struct CreateAlbumForm: View {
    
    @Binding var albumName: String
    @Binding var albumDate: Date
    @Binding var includeDate: Bool
    @Binding var selectedCategory: String
        
    let categories = ["Nenhuma", "Amigos", "Viagem", "Trabalho", "Outros"]
    
    var body: some View {
        Form {
            Section {
                TextField("Nome do álbum", text: $albumName)
            }
            
            Section(header: Text("Preferências")) {
                Toggle("Data", isOn: $includeDate.animation())
                
                if includeDate {
                    DatePicker(
                        "Selecione a data",
                        selection: $albumDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                }
                
                Picker("Categoria", selection: $selectedCategory) {
                    ForEach(categories, id: \.self) { category in
                        Text(category).tag(category)
                    }
                }
                .pickerStyle(.menu)
            }
        }
    }
}
