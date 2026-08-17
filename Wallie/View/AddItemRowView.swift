//
//  AddItemRowView.swift
//  Wallie
//
//  Created by Juan Gabriel Borsacchi Marques on 17/08/26.
//

import SwiftUI

struct AddItemRowView: View {
    @Binding var item: AddItem
    var onRemove: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: item.type.icon)
                    .foregroundStyle(.secondary)
                    .frame(width: 24)

                Spacer()

                Button(role: .destructive, action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            componente
        }
        .padding(.vertical, 6)
    }

    @ViewBuilder
    private var componente: some View {
        switch item.type {
        case .mood:
            MoodPickerRow(selectedMood: moodBinding)
        case .photo:
            PhotoPickerRow(image: imageBinding)
        case .camera:
            CameraCaptureRow(image: imageBinding)
        case .audio:
            AudioRecorderRow(audioURL: audioBinding)
        }
    }


    private var moodBinding: Binding<String> {
        Binding(
            get: {
                if case .mood(let valor) = item.content { return valor }
                return ""
            },
            set: { item.content = .mood($0) }
        )
    }

    private var imageBinding: Binding<UIImage?> {
        Binding(
            get: {
                if case .image(let valor) = item.content { return valor }
                return nil
            },
            set: { novoValor in
                item.content = novoValor.map { .image($0) }
            }
        )
    }

    private var audioBinding: Binding<URL?> {
        Binding(
            get: {
                if case .audio(let valor) = item.content { return valor }
                return nil
            },
            set: { novoValor in
                item.content = novoValor.map { .audio($0) }
            }
        )
    }
}
