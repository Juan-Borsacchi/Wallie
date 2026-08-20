//
//  Untitled.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 15/08/26.
//

import SwiftUI

struct Title: View {
    
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack (alignment: .leading) {
            Text(title)
                .font(.custom("Gupter-Bold", size: 41))
            Text(subtitle)
                .font(.custom("Manrope-Regular", size: 15))
                .foregroundColor(.secondary)
        }
    }
}

struct MemoriesTitles: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        
        VStack(alignment: .leading) {
            Text(title)
                .font(.custom("Manrope-Bold", size: 22))
                .foregroundStyle(Color.corTitulo)
            Text(subtitle)
                .font(.custom("Manrope-Regular", size: 16))
                .foregroundStyle(Color.secondary)

            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
    }
    
}

struct AlertMemories: View {
    var body: some View {
        
        VStack (alignment:  .center) {
            Text("Adicione uma nova experiência para começar a explorar suas memórias.")
                .font(.custom("Manrope-Regular", size: 17))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .frame(width: 350, height: 100)
    }
    
}

#Preview {
    MemoriesTitles(title: "Título", subtitle: "Subtitulo")
}
