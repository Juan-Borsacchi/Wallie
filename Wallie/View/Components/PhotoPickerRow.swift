//
//  PhotoPickerRow.swift
//  Wallie
//
//  Created by Juan Gabriel Borsacchi Marques on 17/08/26.
//


import SwiftUI
import PhotosUI

struct PhotoPickerRow: View {
    @Binding var image: UIImage?
    @State private var selecao: PhotosPickerItem?

    var body: some View {
        PhotosPicker(selection: $selecao, matching: .images) {
            conteudo
        }
        .onChange(of: selecao) { novoValor in
            Task {
                guard let novoValor,
                      let dados = try? await novoValor.loadTransferable(type: Data.self),
                      let uiImage = UIImage(data: dados) else { return }
                image = uiImage
            }
        }
    }

    @ViewBuilder
    private var conteudo: some View {
        if let image {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(height: 160)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        } else {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
                .frame(height: 100)
                .overlay {
                    Label("Escolher da galeria", systemImage: "photo.on.rectangle")
                        .foregroundStyle(.secondary)
                }
        }
    }
}