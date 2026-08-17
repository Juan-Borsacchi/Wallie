//
//  EmptyAlbum.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 15/08/26.
//

import SwiftUI

struct EmptyAlbum: View {
    let emptyAlbumTitle: String
    
    var body: some View {
        VStack(alignment: .leading){
            Text(emptyAlbumTitle)
                .font(.custom("Manrope-Bold", size: 22))
                .foregroundStyle(Color.blue)
            
            HStack {
                Label("Adicione sua primeira experiência", systemImage: "plus.circle.fill")
            }
            .frame(width: 370, height: 76)
            .background(.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 0)
        }
        .padding(.bottom, 20)
    }
}

#Preview {
    EmptyAlbum(emptyAlbumTitle: "Festa de Família")
}
