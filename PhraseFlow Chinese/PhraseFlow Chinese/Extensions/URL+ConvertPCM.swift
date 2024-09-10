//
//  URL+ConvertPCM.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation
import AudioKit

extension URL {
    func convertAudioFileToPCMArray() async throws -> [Float] {
        var options = FormatConverter.Options()
        options.format = .wav
        options.sampleRate = 16000
        options.bitDepth = 16
        options.channels = 1
        options.isInterleaved = false

        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        let converter = FormatConverter(inputURL: self, outputURL: tempURL, options: options)

        return try await withCheckedThrowingContinuation { continuation in
            converter.start { error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                do {

                    let data = try Data(contentsOf: tempURL) // Handle error here

                    let floats = stride(from: 44, to: data.count, by: 2).map {
                        return data[$0..<$0 + 2].withUnsafeBytes {
                            let short = Int16(littleEndian: $0.load(as: Int16.self))
                            return max(-1.0, min(Float(short) / 32767.0, 1.0))
                        }
                    }

                    try FileManager.default.removeItem(at: tempURL)

                    continuation.resume(returning: floats)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
