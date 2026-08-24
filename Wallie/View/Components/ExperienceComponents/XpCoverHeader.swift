//
//  XpCoverHeader.swift
//  Wallie
//
//  Created by Juan Gabriel Borsacchi Marques on 20/08/26.
//

import SwiftUI

struct XpCoverHeader: View {
    @Binding var coverImage: UIImage?
    let onSelectPhoto: () -> Void
    let onTakePhoto: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            
            VStack(alignment: .leading, spacing: 12) {
                
                Label("Capa da Experiência", systemImage: "camera.fill")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                if let image = coverImage {
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, minHeight: 220, maxHeight: 320)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
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
                
                HStack(spacing: 12) {
                    
                    Button(action: onSelectPhoto) {
                        Text(coverImage == nil ? "Acessar Galeria" : "Trocar foto")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(Color.primary.opacity(0.15), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: onTakePhoto) {
                        Text(coverImage == nil ? "Tirar foto" : "Tirar outra")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(coverImage == nil ? .white : MomentosPalette.accentSoft)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background {
                                if coverImage == nil {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(MomentosPalette.accentSoft)
                                } else {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(MomentosPalette.accentSoft, lineWidth: 1.5)
                                }
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(14)
            .background(
                Color(.systemBackground),
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
            
            Text("Campo obrigatório.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.leading, 12)
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    @Previewable @State var sampleImage: UIImage? = nil
    
    XpCoverHeader(
        coverImage: $sampleImage,
        onSelectPhoto: { print("Selecionar foto") },
        onTakePhoto: { print("Tirar foto") }
    )
}
