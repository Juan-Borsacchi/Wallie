//
//  EmptyAlbum.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 15/08/26.
//

import SwiftUI

struct AlbumEmpty: View {
    let emptyAlbumTitle: String
    
    var body: some View {
        VStack(alignment: .leading){
            Text(emptyAlbumTitle)
                .font(.custom("Manrope-Bold", size: 22))
                .foregroundStyle(Color(.colorTitle))
            
            HStack {
                Label("Adicione sua primeira experiência", systemImage: "plus.circle.fill")
            }
            .frame(width: 370, height: 76)
            .foregroundStyle(.primary)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.primary.opacity(0.4), radius: 1, x: 0, y: 0)
        }
        .padding(.bottom, 20)
    }
}

#Preview {
    AlbumEmpty(emptyAlbumTitle: "Festa de Família")
}
