//
//  MomentsAddButton.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 21/08/26.
//

import SwiftUI

struct MomentsAddButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Label("Adicionar experiência", systemImage: "plus.circle.fill")
                .font(.headline)
                .foregroundStyle(.white)
                .padding(8)
        }
        .buttonStyle(.glassProminent)
        .tint(.colorAddMoment)
        .padding(.horizontal, 16)
    }
}

#Preview {
    MomentsAddButton(action : {})
}
