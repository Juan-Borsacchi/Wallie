//
//  ToolBarViewsTitle.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 16/08/26.
//

import SwiftUI

struct ToolBarViewsTitle: View {
    @Environment(\.colorScheme) var colorScheme
    
    let title: String
    let subtitle: String?
    var showEditButton: Bool = true
    var isEditingMode: Bool = false
    var onAdd: () -> Void
    var onEditToggle: (() -> Void)? = nil
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.custom("Gupter-Bold", size: 34))
                    .foregroundStyle(.primary)
                
                if let subtitle {
                    Text(subtitle)
                        .font(.custom("Manrope-Regular", size: 14))
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                if showEditButton, let onEditToggle {
                    Button(action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            onEditToggle()
                        }
                    }) {
                        ZStack {
                            if isEditingMode {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.white)
                                    .transition(.scale.combined(with: .opacity))
                            } else {
                                Text("Editar")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 16)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .frame(height: 38)
                        .frame(minWidth: isEditingMode ? 38 : 0)
                        .background {
                            Group {
                                if isEditingMode {
                                    Circle()
                                        .fill(Color.verdeProjeto)
                                } else {
                                    Capsule()
                                        .fill(.thinMaterial)
                                        .overlay(
                                            Capsule()
                                                .stroke(
                                                    LinearGradient(
                                                        colors: colorScheme == .dark ? [
                                                            .white.opacity(0.18),
                                                            .white.opacity(0.03)
                                                        ] : [
                                                            .black.opacity(0.12),
                                                            .white.opacity(0.5)
                                                        ],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: 1
                                                )
                                        )
                                }
                            }
                        }
                        .shadow(
                            color: .black.opacity(colorScheme == .dark ? 0.3 : 0.08),
                            radius: 8,
                            x: 0,
                            y: 4
                        )
                    }
                }
                
                Button(action: onAdd) {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 38, height: 38)
                        .background(Color.colorAddButton)
                        .clipShape(Circle())
                }
            }
        }
    }
}
