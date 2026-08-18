//
//  ToolBars.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 14/08/26.
//

import SwiftUI

struct ToolBarSelectedAlbum: View {
    var onSearching: () -> Void
    var onAdd: () -> Void
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Text("Mémorias")
                .font(.custom("Gupter-Bold", size: 41))
            Spacer()
            Button(action: onSearching) {
                Image(systemName: "magnifyingglass")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .buttonStyle(.glassProminent)
                    .foregroundColor(.primary)
            }
            Button(action: onAdd) {
                Image(systemName: "plus")
                    .font(.title2)
                    .buttonStyle(.glassProminent)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 10)
    }
    
}
