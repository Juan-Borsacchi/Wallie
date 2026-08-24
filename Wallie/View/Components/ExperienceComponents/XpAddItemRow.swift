//
//  AddItemRowView.swift
//  Wallie
//
//  Created by Juan Gabriel Borsacchi Marques on 17/08/26.
//

import SwiftUI
import AVFoundation
import PhotosUI

struct XpAddItemRow: View {
    @Binding var item: AddItem
    var onRemove: () -> Void
    
    @State private var activeSheet: ActiveSheet?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: item.type.icon)
                    .foregroundStyle(.secondary)
                    .frame(width: 24)
                
                Spacer()
                
                Button(role: .destructive, action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(.secondary)
                        .padding(8)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                
            }
            
            componente
        }
        .padding(.vertical, 6)
        .onAppear {
            if item.type == .audio && audioBinding.wrappedValue == nil {
                activeSheet = .audioRecorder
            } else if item.type == .photo && imagesBinding.wrappedValue.isEmpty {
                activeSheet = .photoPicker
            }
        }
        .sheet(item: $activeSheet) { sheetType in
            switch sheetType {
            case .audioRecorder:
                AudioRecorderSheetView(audioURL: audioBinding)
                    .presentationDetents([.height(350)])
                    .presentationCornerRadius(30)
                    .presentationDragIndicator(.visible)
                
            case .photoPicker:
                PhotoPickerSheetView(selectedImages: imagesBinding)
                    .presentationDetents([.height(350), .medium])
                    .presentationCornerRadius(30)
                    .presentationDragIndicator(.visible)
            }
        }
    }
    
    @ViewBuilder
    private var componente: some View {
        switch item.type {
        case .mood:
            XpMoodPicker(selectedQuality: qualityBinding, selectedEmotion: emotionBinding)
            
        case .photo:
            let images = imagesBinding.wrappedValue
            if !images.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(images.enumerated()), id: \.offset) { index, image in
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 110, height: 110)
                                    .cornerRadius(12)
                                    .clipped()
                                
                                Button {
                                    var current = imagesBinding.wrappedValue
                                    current.remove(at: index)
                                    imagesBinding.wrappedValue = current
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 18))
                                        .foregroundStyle(.white, .black.opacity(0.6))
                                        .padding(4)
                                }
                            }
                        }
                    }
                }
            } else {
                Button(action: { activeSheet = .photoPicker }) {
                    HStack {
                        Image(systemName: "photo.on.rectangle.angled")
                        Text("Escolher Fotos")
                    }
                    .font(.subheadline.bold())
                    .foregroundStyle(.indigo)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.indigo.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
            
        case .camera:
            XpCameraCapture(image: singleImageBinding)
            
        case .audio:
            if let audioURL = audioBinding.wrappedValue {
                AudioPlayerCardView(audioURL: audioURL) {
                    item.content = nil
                }
            } else {
                Button(action: { activeSheet = .audioRecorder }) {
                    HStack {
                        Image(systemName: "mic.fill")
                        Text("Gravar Áudio")
                    }
                    .font(.subheadline.bold())
                    .foregroundStyle(.indigo)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.indigo.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var qualityBinding: Binding<QualityRating?> {
        Binding(
            get: {
                if case let .mood(quality, _) = item.content { return quality }
                return nil
            },
            set: { newValue in
                if case let .mood(_, emotion) = item.content {
                    item.content = .mood(quality: newValue, emotion: emotion)
                } else {
                    item.content = .mood(quality: newValue, emotion: nil)
                }
            }
        )
    }
    
    private var emotionBinding: Binding<EmotionTag?> {
        Binding(
            get: {
                if case let .mood(_, emotion) = item.content { return emotion }
                return nil
            },
            set: { newValue in
                if case let .mood(quality, _) = item.content {
                    item.content = .mood(quality: quality, emotion: newValue)
                } else {
                    item.content = .mood(quality: nil, emotion: newValue)
                }
            }
        )
    }
    
    private var imagesBinding: Binding<[UIImage]> {
            Binding(
                get: {
                    if case .images(let valoresData) = item.content {
                        return valoresData.compactMap { UIImage(data: $0) }
                    }
                    return []
                },
                set: { novasImagens in
                    let datas = novasImagens.compactMap { $0.jpegData(compressionQuality: 0.8) }
                    item.content = datas.isEmpty ? nil : .images(datas)
                }
            )
        }
    
    private var singleImageBinding: Binding<UIImage?> {
            Binding(
                get: {
                    if case .images(let valoresData) = item.content, let firstData = valoresData.first {
                        return UIImage(data: firstData)
                    }
                    return nil
                },
                set: { novoValor in
                    if let image = novoValor, let data = image.jpegData(compressionQuality: 0.8) {
                        item.content = .images([data])
                    } else {
                        item.content = nil
                    }
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

struct PhotoPickerSheetView: View {
    @Binding var selectedImages: [UIImage]
    @Environment(\.dismiss) private var dismiss
    @State private var selectedItems: [PhotosPickerItem] = []
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Selecione suas Fotos")
                .font(.headline)
                .padding(.top, 20)
            
            PhotosPicker(
                selection: $selectedItems,
                maxSelectionCount: 10,
                matching: .images
            ) {
                VStack(spacing: 8) {
                    Image(systemName: "photo.stack.fill")
                        .font(.system(size: 36))
                    Text("Abrir Galeria")
                        .font(.subheadline.bold())
                }
                .foregroundStyle(.indigo)
                .frame(maxWidth: .infinity)
                .frame(height: 140)
                .background(Color.indigo.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .onChange(of: selectedItems) { _, newItems in
            Task {
                var loaded: [UIImage] = []
                for item in newItems {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        loaded.append(image)
                    }
                }
                
                await MainActor.run {
                    self.selectedImages = loaded
                    dismiss()
                }
            }
        }
    }
}

struct AudioWaveformView: View {
    var samples: [CGFloat]
    var barColor: Color = Color.indigo
    var barSpacing: CGFloat = 3
    
    var body: some View {
        HStack(spacing: barSpacing) {
            ForEach(0..<samples.count, id: \.self) { index in
                Capsule()
                    .fill(barColor)
                    .frame(height: max(4, samples[index] * 40))
            }
        }
        .frame(height: 50)
    }
}

struct AudioRecorderSheetView: View {
    @Binding var audioURL: URL?
    @Environment(\.dismiss) private var dismiss
    
    @State private var isRecording = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var liveSamples: [CGFloat] = Array(repeating: 0.1, count: 30)
    
    @State private var audioRecorder: AVAudioRecorder?
    @State private var timer: Timer?
    
    var body: some View {
        VStack {
            Text(formattedTime(elapsedTime))
                .font(.system(size: 16, weight: .medium, design: .monospaced))
                .foregroundStyle(.secondary)
                .padding(.top, 24)
            
            Spacer()
            
            if isRecording {
                AudioWaveformView(samples: liveSamples, barColor: .indigo)
                    .padding(.horizontal, 24)
            } else {
                Text("Iniciar Gravação de Áudio")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Button {
                toggleRecording()
            } label: {
                ZStack {
                    Circle()
                        .stroke(Color.primary.opacity(0.15), lineWidth: 4)
                        .frame(width: 75, height: 75)
                    
                    Circle()
                        .fill(Color.red)
                        .frame(width: isRecording ? 35 : 62, height: isRecording ? 35 : 62)
                        .cornerRadius(isRecording ? 8 : 31)
                }
            }
            .padding(.bottom, 36)
        }
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.secondarySystemBackground))
        .onDisappear {
            stopRecordingProcess()
        }
    }
    
    private func toggleRecording() {
        if isRecording {
            stopRecordingProcess()
            dismiss()
        } else {
            startRecordingProcess()
        }
    }
    
    private func startRecordingProcess() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)
            
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("recording_\(Date().timeIntervalSince1970).m4a")
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            
            audioURL = url
            elapsedTime = 0
            withAnimation { isRecording = true }
            
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                guard let recorder = audioRecorder, recorder.isRecording else { return }
                recorder.updateMeters()
                
                elapsedTime = recorder.currentTime
                
                let power = recorder.averagePower(forChannel: 0)
                let normalized = max(0.1, CGFloat((power + 60) / 60))
                
                withAnimation(.linear(duration: 0.08)) {
                    liveSamples.removeFirst()
                    liveSamples.append(normalized)
                }
            }
        } catch {
            print("Erro ao iniciar gravação: \(error)")
        }
    }
    
    private func stopRecordingProcess() {
        audioRecorder?.stop()
        timer?.invalidate()
        timer = nil
        isRecording = false
    }
    
    private func formattedTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct AudioPlayerCardView: View {
    let audioURL: URL
    var onDelete: () -> Void
    
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var sampleAmplitudes: [CGFloat] = [
        0.2, 0.4, 0.7, 0.5, 0.3, 0.8, 1.0, 0.6, 0.4, 0.2,
        0.5, 0.9, 0.7, 0.3, 0.6, 0.8, 0.4, 0.2, 0.5, 0.7
    ]
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                Button(action: togglePlay) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(Circle().fill(Color.indigo))
                }
                
                Text(formattedDuration)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Image(systemName: "quote.bubble")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Button(action: {
                    stopAudio()
                    onDelete()
                }) {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            AudioWaveformView(samples: sampleAmplitudes, barColor: .indigo)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.indigo.opacity(0.18))
        )
        .onDisappear {
            stopAudio()
        }
    }
    
    private var formattedDuration: String {
        let duration = audioPlayer?.duration ?? 0
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func togglePlay() {
        if isPlaying {
            audioPlayer?.pause()
            isPlaying = false
        } else {
            do {
                if audioPlayer == nil {
                    audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
                }
                audioPlayer?.play()
                isPlaying = true
            } catch {
                print("Erro ao tocar áudio: \(error)")
            }
        }
    }
    
    private func stopAudio() {
        audioPlayer?.stop()
        isPlaying = false
    }
}

#Preview {
    @Previewable @State var item = AddItem(type: .mood)
    
    XpAddItemRow(item: $item) {}
        .padding()
}
