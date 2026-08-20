//
//  ExperienceCoverHeaderView.swift
//  Wallie
//
//  Created by Juan Gabriel Borsacchi Marques on 20/08/26.
//

import SwiftUI

struct ExperienceCoverHeaderView: View {
    @Binding var coverImage: UIImage?
    let onSelectPhoto: () -> Void
    let onTakePhoto: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            
            VStack(alignment: .leading, spacing: 10) {
                
                // MARK: - Título da Seção com Ícone
                Label("Capa da Experiência", systemImage: "photo.on.rectangle")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                // MARK: - Preview da Imagem
                if let image = coverImage {
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, minHeight: 220, maxHeight: 320)
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .overlay {
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
                            }
                        
                        Button {
                            withAnimation { coverImage = nil }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(.white, .black.opacity(0.55))
                                .padding(10)
                        }
                    }
                }
                
                // MARK: - Botões de Seleção
                HStack(spacing: 12) {
                    Button(action: onSelectPhoto) {
                        Label(
                            coverImage == nil ? "Acessar Galeria" : "Trocar foto",
                            systemImage: "photo"
                        )
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: onTakePhoto) {
                        Label(
                            coverImage == nil ? "Tirar foto" : "Tirar outra",
                            systemImage: coverImage == nil ? "camera.fill" : "camera"
                        )
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(coverImage == nil ? .white : .primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            coverImage == nil ? MomentosPalette.accentSoft : Color(.systemBackground),
                            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            
            // Texto explicativo fora e abaixo da seção da capa
            Text("Campo obrigatório.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.leading, 12)
        }
        .padding(.horizontal, 16)
    }
}
