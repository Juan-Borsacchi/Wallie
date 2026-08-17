//
//  CreateMomentForm.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 16/08/26.
//

import SwiftUI

struct CreateMomentForm: View {
    
    @Binding var newTitle: String
    @Binding var description: String
    @Binding var includeDate: Bool
    @Binding var momentData: Date
    @Binding var moveToAlbum: String
    
    let moveAlbuns = ["Nenhum", "Album 1", "Album 2", "Album 3", "Album 4"]
    
    var body: some View {
        Form {
            Section {
                TextField("Título", text: $newTitle)
                
                TextField("Escreva uma descrição", text: $description, axis: .vertical)
                    .lineLimit(3...5)
            }
            Section(header: Text("Preferências")) {
                Toggle("Data", isOn: $includeDate.animation())
                
                if includeDate {
                    DatePicker(
                        "Selecione a data",
                        selection: $momentData,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                }
                
                Picker("Mover para álbum", selection: $moveToAlbum) {
                    ForEach(moveAlbuns, id: \.self) { move in
                        Text(move).tag(move)
                    }
                }
                .pickerStyle(.menu)
            }
        }
    }
}
    
#Preview {
    @Previewable @State var newTitle = ""
    @Previewable @State var description = ""
    @Previewable @State var includeDate = false
    @Previewable @State var momentData = Date()
    @Previewable @State var moveToAlbum = "Nenhum"
    
    CreateMomentForm(
        newTitle: $newTitle,
        description: $description,
        includeDate: $includeDate,
        momentData: $momentData,
        moveToAlbum: $moveToAlbum
    )
}
