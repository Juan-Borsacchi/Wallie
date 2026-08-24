//
//  XpGlassCard.swift
//  Wallie
//
//  Created by Juan Gabriel Borsacchi Marques on 20/08/26.
//

import SwiftUI

struct XpGlassCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(spacing: 16) {
            Text(title.isEmpty ? "Sem título" : title)
                .font(.custom("Georgia", size: 26))
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top)
            
            content
        }
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 32, style: .continuous))
        .environment(\.colorScheme, .dark)
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.6), .white.opacity(0.1), .clear, .white.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: .black.opacity(0.25), radius: 15, x: 0, y: 10)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
}

#Preview {
    ZStack {
        Color.indigo
            .ignoresSafeArea()
        
        XpGlassCard(title: "text") {
            Text("text")
                .foregroundStyle(.white)
                .padding()
        }
    }
}
