//
//  AlbumTagCategory.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 16/08/26.
//

import SwiftUI

struct AlbumTagCategory: View {
    @Environment(\.colorScheme) private var colorScheme
    var nameCategory: String
    
    var body: some View {
        VStack {
            Text(nameCategory)
                .font(.custom("Manrope-Regular", size: 17))
                .foregroundStyle(colorScheme == .dark ? .white : .primary )
        }
        .padding(.horizontal, 16)
        .frame(height: 32)
        .background(colorScheme == .dark ? .black : .white)
        .cornerRadius(20)
        .overlay(
            Capsule()
                .strokeBorder(Color(.separator), lineWidth: 1)
        )
    }
}

#Preview {
    AlbumTagCategory(nameCategory: "Categoria")
}
