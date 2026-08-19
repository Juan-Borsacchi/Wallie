//
//  AudioRecorderRow.swift
//  Wallie
//
//  Created by Juan Gabriel Borsacchi Marques on 17/08/26.
//


import SwiftUI

struct AudioRecorderRow: View {
    @Binding var audioURL: URL?
    @StateObject private var gravador = AudioRecorder()

    var body: some View {
        HStack(spacing: 16) {
            Button {
                if gravador.isRecording {
                    gravador.stopRecord { url in
                        audioURL = url
                    }
                } else {
                    gravador.StartRecord()
                }
            } label: {
                Image(systemName: gravador.isRecording ? "stop.circle.fill" : "record.circle")
                    .font(.system(size: 32))
                    .foregroundStyle(gravador.isRecording ? .red : .accentColor)
            }
            .buttonStyle(.plain)

            if gravador.isRecording {
                Text(gravador.formatedTime)
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.secondary)
            } else if audioURL != nil {
                Label("Áudio gravado", systemImage: "waveform")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                Text("Toque para gravar")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}
