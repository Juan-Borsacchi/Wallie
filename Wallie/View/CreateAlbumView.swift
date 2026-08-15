//
//  CreateAlbumView.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 15/08/26.
//
import SwiftUI

struct CreateAlbumView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State private var albumName: String = ""
    @State private var albumDate: Date = Date()
    @State private var includeDate: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Nome do álbum", text: $albumName)
                
                Section {
                    Toggle("Data", isOn: $includeDate.animation())
                    
                    if includeDate {
                        DatePicker(
                            "Selecione a data",
                            selection: $albumDate,
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(.graphical)
                    }
                }
            }
            
        }
    }
}

#Preview {
    CreateAlbumView()
}
