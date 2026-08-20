//
//  AudioPlayerRow.swift
//  Wallie
//
//  Created by Juan Gabriel Borsacchi Marques on 20/08/26.
//

import SwiftUI

struct AudioPlayerRow: View {
    let url: URL
    let isPlaying: Bool
    let onTogglePlay: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Button(action: onTogglePlay) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Gravação de Áudio")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                Text(isPlaying ? "Reproduzindo..." : "Toque para ouvir")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.75))
            }
            
            Spacer()
            
            Image(systemName: "waveform")
                .font(.title3)
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
