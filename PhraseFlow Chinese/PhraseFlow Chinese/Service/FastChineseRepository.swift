//
//  FastChineseRepository.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation
import SwiftWhisper

enum FastChineseRepositoryError: Error {
    case failedToSegment
}

protocol FastChineseRepositoryProtocol {
    var whisper: Whisper? { get set }
    func transcribe(audioFrames: [Float]) async throws-> [Segment]
}

class FastChineseRepository: FastChineseRepositoryProtocol {

    var whisper: Whisper?

    init() {
        if let modelUrl = Bundle.main.url(forResource: "ggml-tiny", withExtension: "bin") {
            let params = WhisperParams()
            params.max_len = 1
            params.token_timestamps = true
            self.whisper = Whisper(fromFileURL: modelUrl, withParams: params)
        }
    }

    func transcribe(audioFrames: [Float]) async throws-> [Segment] {
        guard let segments = try await whisper?.transcribe(audioFrames: audioFrames) else {
            throw FastChineseRepositoryError.failedToSegment
        }
        return segments
    }
}
