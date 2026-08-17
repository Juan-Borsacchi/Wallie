//
//  AddMoment.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 16/08/26.
//

import SwiftUI

struct AddMoment: View {
    
    @Binding var displaySheet: Bool

    var body: some View {
        
        Button(action: {
            displaySheet = true
        }) {
            Label("Adicionar experiencia", systemImage: "plus.circle.fill")
                .font(.headline)
                .foregroundStyle(.white)
                .padding(8)
        }
        .buttonStyle(.glassProminent)
        .tint(.green)
        .padding(.horizontal, 16)
        .padding(.vertical, 50)
    }
}
