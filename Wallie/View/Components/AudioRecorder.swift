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
    @Published var isRecording = false
    @Published var formatedTime = "00:00"

    private var recorder: AVAudioRecorder?
    private var timer: Timer?
    private var recordStart: Date?

    func StartRecord() {
        AVAudioApplication.requestRecordPermission { [weak self] permited in
            guard permited else { return }
            
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

            let archive = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("m4a")

            let config: [String: Any] = [
                AVFormatIDKey: kAudioFormatMPEG4AAC,
                AVSampleRateKey: 44_100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            recorder = try AVAudioRecorder(url: archive, settings: config)
            recorder?.record()
            isRecording = true
            recordStart = Date()

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
        isRecording = false
        formatedTime = "00:00"
        completion(recorder?.url)
    }

    private func timeRefresh() {
        guard let start = recordStart else { return }
        let interval = Int(Date().timeIntervalSince(start))
        formatedTime = String(format: "%02d:%02d", interval / 60, interval % 60)
    }
}
