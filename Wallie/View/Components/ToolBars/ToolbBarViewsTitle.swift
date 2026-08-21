//
//  ToolbBarAlbum.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 16/08/26.
//

import SwiftUI

struct ToolBarViewsTitle: View {
    let title: String
    let subtitle: String?
    var onAdd: () -> Void
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.custom("Gupter-Bold", size: 41))
                if let subtitle {
                    Text(subtitle)
                        .font(.custom("Manrope-Regular", size: 15))
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            HStack {
                Button(action: onAdd) {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(.corTitulo)
                        .clipShape(Circle())
                }
            }
        }
    }
}

