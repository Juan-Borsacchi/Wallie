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
                .foregroundStyle(Color.azulProjeto)
            Text(subtitle)
                .font(.custom("Manrope-Regular", size: 16))
                .foregroundStyle(Color.gray)

            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
    }
    
}



#Preview {
    MemoriesTitles(title: "Título", subtitle: "Subtitulo")
}
