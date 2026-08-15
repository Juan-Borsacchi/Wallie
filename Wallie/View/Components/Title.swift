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

#Preview {
    Title(title: "Título", subtitle: "Subtitulo")
}
