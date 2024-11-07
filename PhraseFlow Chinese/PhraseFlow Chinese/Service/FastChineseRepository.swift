//
//  FastChineseRepository.swift
//  FastChinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation
import MicrosoftCognitiveServicesSpeech

protocol FastChineseRepositoryProtocol {
    func synthesizeSpeech(_ chapter: Chapter, voice: Voice, rate: String) async throws -> (wordTimestamps: [WordTimeStampData],
                                                           audioData: Data)
}

class FastChineseRepository: FastChineseRepositoryProtocol {

    init() {

    }

    func synthesizeSpeech(_ chapter: Chapter, voice: Voice, rate: String) async throws -> (wordTimestamps: [WordTimeStampData], audioData: Data) {
        // Replace with your subscription key and service region
        let speechKey = "144bc0cdea4d44e499927e84e795b27a"
        let serviceRegion = "eastus"

        do {
            // Initialize speech configuration
            let speechConfig = try SPXSpeechConfiguration(subscription: speechKey, region: serviceRegion)
            speechConfig.requestWordLevelTimestamps()
            speechConfig.setSpeechSynthesisOutputFormat(.riff16Khz16BitMonoPcm) // Use a format compatible with AVAudioPlayer
            speechConfig.speechSynthesisVoiceName = voice.speechSynthesisVoiceName

            // Create a speech synthesizer
            let synthesizer = try SPXSpeechSynthesizer(speechConfiguration: speechConfig, audioConfiguration: nil)

            // Create an array to hold words, timestamps, and offsets
            var wordTimestamps: [WordTimeStampData] = []
            let wordTimestampsQueue = DispatchQueue(label: "WordTimestampsQueue")

            // Add a handler for the word boundary event
            var textOffset = 0
            var index = -1
            synthesizer.addSynthesisWordBoundaryEventHandler { (synthesizer, event) in
                // Extract the audio offset (in ticks of 100 nanoseconds)
                let audioTimeInSeconds = Double(event.audioOffset) / 10_000_000.0

                // Extract the word from the text using textOffset and wordLength
                let word = event.text
                    .replacingOccurrences(of: "\n", with: "")
                    .replacingOccurrences(of: " ", with: "")
                let wordLength = word.count

                // Append the word, its timestamp, and offsets to the array
                wordTimestampsQueue.sync {
                    wordTimestamps.append(.init(word: word,
                                                time: audioTimeInSeconds,
                                                duration: event.duration,
                                                textOffset: textOffset,
                                                wordLength: wordLength))
                    if var newTimestamp = wordTimestamps[safe: index] {
                        newTimestamp.duration = audioTimeInSeconds - newTimestamp.time - 0.0001
                        wordTimestamps[index] = newTimestamp
                    }
                    index += 1

                    textOffset += wordLength
                }
            }

            // Generate the SSML text with the specified rate
            var ssml = """
            <speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="https://www.w3.org/2001/mstts" xml:lang="zh-CN">
            <voice name="\(voice.speechSynthesisVoiceName)">
            """
            // TODO: Update to be able to speak male characters as male voice, storyteller as female, and female characters as same female voice
            for sentence in chapter.sentences {
                let splitSentence = splitSpeechAndNonSpeech(from: sentence.mandarin)
                for sentenceSection in splitSentence {
                    // TODO: Update styleDegree to also be generated with each sentence
                    let isSpeech = sentenceSection.contains("“") || sentenceSection.contains("”")
                    let sentenceSsml = """
                <mstts:express-as style="\(isSpeech ? sentence.speechStyle.ssmlName : SpeechStyle.lyrical.ssmlName)" styledegree="1">
                    <prosody rate="\(rate)">
                        \(sentenceSection)
                    </prosody>
                </mstts:express-as>
                """
                    ssml.append(sentenceSsml)
                }
            }
            let ssmlSuffix = """
                        </voice>
                        </speak>
            """
            ssml.append(ssmlSuffix)

            // Start speech synthesis synchronously using SSML
            let result = try synthesizer.speakSsml(ssml)

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

    private func splitSpeechAndNonSpeech(from text: String) -> [String] {
        var results: [String] = []
        var currentText = ""
        var isInSpeech = false

        for character in text {
            if character == "“" || character == "”" {
                if isInSpeech {
                    // End of speech part, include closing quotation mark
                    currentText.append(character)
                    results.append(currentText)
                    currentText = ""
                } else {
                    // Non-speech part ends, start of speech part
                    if !currentText.isEmpty {
                        results.append(currentText)
                        currentText = ""
                    }
                    currentText.append(character) // Start with the opening quotation mark
                }
                isInSpeech.toggle()
            } else {
                // Append character to current part
                currentText.append(character)
            }
        }

        // Add any remaining non-speech text after the last quotation mark
        if !currentText.isEmpty {
            results.append(currentText)
        }

        if results.count > 1 {
            print("Results is \(results)")
        }

        return results
    }

}
