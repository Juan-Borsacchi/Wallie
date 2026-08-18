//
//  AudioRecorder.swift
//  Wallie
//
//  Created by Juan Gabriel Borsacchi Marques on 17/08/26.
//

import Foundation
import AVFoundation
import Combine

@MainActor
final class AudioRecorder: NSObject, ObservableObject {
    @Published var estaGravando = false
    @Published var tempoFormatado = "00:00"

    private var recorder: AVAudioRecorder?
    private var timer: Timer?
    private var inicioGravacao: Date?

    func iniciarGravacao() {
        AVAudioApplication.requestRecordPermission { [weak self] permitido in
            guard permitido else { return }
            
            // Garante o isolamento no MainActor ao acessar o self
            Task { @MainActor [weak self] in
                self?.startwithpermission()
            }
        }
    }

    private func startwithpermission() {
        let sessao = AVAudioSession.sharedInstance()
        do {
            try sessao.setCategory(.playAndRecord, mode: .default)
            try sessao.setActive(true)

            let arquivo = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("m4a")

            let config: [String: Any] = [
                AVFormatIDKey: kAudioFormatMPEG4AAC,
                AVSampleRateKey: 44_100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            recorder = try AVAudioRecorder(url: arquivo, settings: config)
            recorder?.record()
            estaGravando = true
            inicioGravacao = Date()

            // Passando o bloco do Timer para o MainActor de forma segura
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.timeRefresh()
                }
            }
        } catch {
            print("Erro ao iniciar gravação: \(error)")
        }
    }

    func stopRecord(completion: @escaping (URL?) -> Void) {
        recorder?.stop()
        timer?.invalidate()
        estaGravando = false
        tempoFormatado = "00:00"
        completion(recorder?.url)
    }

    private func timeRefresh() {
        guard let inicio = inicioGravacao else { return }
        let intervalo = Int(Date().timeIntervalSince(inicio))
        tempoFormatado = String(format: "%02d:%02d", intervalo / 60, intervalo % 60)
    }
}
