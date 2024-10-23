//
//  FastChineseRepository.swift
//  FastChinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation
import MicrosoftCognitiveServicesSpeech

enum FastChineseRepositoryError: Error {
    case failedToSegment
    case failedToCreateSPXSpeechConfiguration
}

protocol FastChineseRepositoryProtocol {
    func synthesizeSpeech(_ text: String) async throws -> (wordTimestamps: [WordTimeStampData],
                                                           audioData: Data)
}

class FastChineseRepository: FastChineseRepositoryProtocol {

    init() {

    }

    func synthesizeSpeech(_ text: String) async throws -> (wordTimestamps: [WordTimeStampData], audioData: Data) {
        // Replace with your subscription key and service region
        let speechKey = "144bc0cdea4d44e499927e84e795b27a"
        let serviceRegion = "eastus"

        do {
            // Initialize speech configuration
            let speechConfig = try SPXSpeechConfiguration(subscription: speechKey, region: serviceRegion)
            speechConfig.requestWordLevelTimestamps()
            speechConfig.setSpeechSynthesisOutputFormat(.riff16Khz16BitMonoPcm) // Use a format compatible with AVAudioPlayer
            speechConfig.speechSynthesisVoiceName = "zh-CN-XiaoxiaoNeural"

            // Create an audio configuration to prevent audio from playing to the speaker
            let audioConfig = SPXAudioConfiguration()

            // Create a speech synthesizer
            let synthesizer = try SPXSpeechSynthesizer(speechConfiguration: speechConfig, audioConfiguration: audioConfig)

            // Create an array to hold words, timestamps, and offsets
            var wordTimestamps: [WordTimeStampData] = []
            let wordTimestampsQueue = DispatchQueue(label: "WordTimestampsQueue")

            // Add a handler for the word boundary event
            synthesizer.addSynthesisWordBoundaryEventHandler { (synthesizer, event) in
                // Extract the audio offset (in ticks of 100 nanoseconds)
                let audioTimeInSeconds = Double(event.audioOffset) / 10_000_000.0

                // Extract the word from the text using textOffset and wordLength
                let textOffset = Int(event.textOffset)
                let wordLength = Int(event.wordLength)
                let start = text.index(text.startIndex, offsetBy: textOffset)
                let end = text.index(start, offsetBy: wordLength)
                let word = String(text[start..<end])

                // Append the word, its timestamp, and offsets to the array
                wordTimestampsQueue.sync {
                    wordTimestamps.append(.init(word: word,
                                                time: audioTimeInSeconds,
                                                duration: event.duration,
                                                textOffset: textOffset,
                                                wordLength: wordLength))
                }
            }

            // Start speech synthesis synchronously
            let result = try synthesizer.speakText(text)
            // TODO: get audioDuration, then use this to automatically go to next sentence, and play the sentence.
            // TODO: Update syhtnesize speech to synthesize the current sentence, and the next sentence, at the same time, to allow for smooth playing through the story

            // Check the result for cancellation
            if result.reason == SPXResultReason.canceled {
                let cancellationDetails = try SPXSpeechSynthesisCancellationDetails(fromCanceledSynthesisResult: result)
                let errorDetails = cancellationDetails.errorDetails ?? "Unknown error"
                throw NSError(domain: "SpeechSynthesis", code: -1, userInfo: [NSLocalizedDescriptionKey: errorDetails])
            }

            guard let audioData = result.audioData else {
                throw NSError(domain: "SpeechSynthesis", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get audioData"])
            }

            // Return the collected word timestamps and audio data
            return (wordTimestamps, audioData)

        } catch {
            throw error
        }
    }
}
