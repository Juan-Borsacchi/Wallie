//
//  AlbunsView.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 15/08/26.
//

import SwiftUI

struct AlbunsView: View {
    @State private var displaySheet = false
    
    var body: some View {
        
        NavigationStack {
            ScrollView {
                
                VStack (alignment: .leading) {
                    HStack {
                        Title(title: "Álbuns", subtitle: "Colecione mémorias")
                        Spacer()
                        AddButton(displaySheet: $displaySheet)
                    }
                    .padding(.bottom, 27)
                    
                    AlbumGroup(titleAlbum: "Viagem pro Chile")
                    EmptyAlbum(emptyAlbumTitle: "Festa de Familia")
                    AlbumGroup(titleAlbum: "Passeios no parque")
                }
                .padding(16)
            }
            .sheet(isPresented: $displaySheet) {
                CreateAlbumView()
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.large])
            }
        }
    }
}

#Preview {
    AlbunsView()
}
