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
    @State private var selectedCategory: String = "Nenhuma"
    
    var body: some View {
        NavigationStack {
            CreateAlbumForm(
                albumName: $albumName,
                albumDate: $albumDate,
                includeDate: $includeDate,
                selectedCategory: $selectedCategory
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolBarCreateSheetAlbum(
                    cancelAction: {
                        dismiss()
                    },
                    confirmAction: {
                        dismiss()
                    }
                )
            }
        }
    }
}

#Preview {
    CreateAlbumView()
}
