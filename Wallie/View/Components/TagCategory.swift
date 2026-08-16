//
//  TagCategoria.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 16/08/26.
//

import SwiftUI

struct TagCategory: View {
    
    var nameCategory: String
    
        var body: some View {
        
        VStack {
            Text(nameCategory)
                .font(.custom("Manrope-Bold", size: 17))
                .foregroundStyle(Color.white)
        }
        .padding(.horizontal, 16)
        .frame(height: 32)
        .background(Color.blue)
        .cornerRadius(20)
    }
}

#Preview {
    TagCategory(nameCategory: "Categoria")
}
