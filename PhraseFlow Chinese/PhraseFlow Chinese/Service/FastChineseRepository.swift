//
//  FastChineseRepository.swift
//  FastChinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation
import MicrosoftCognitiveServicesSpeech

protocol FastChineseRepositoryProtocol {
    func synthesizeSpeech(_ chapter: Chapter, voice: Voice, rate: String, language: Language?) async throws -> (wordTimestamps: [WordTimeStampData],
                                                                                           audioData: Data)
}

class FastChineseRepository: FastChineseRepositoryProtocol {

    private let speechCharacters = [
        "“",
        "”",
        "\"",
        "''"
    ]

    init() { }

    func synthesizeSpeech(_ chapter: Chapter, voice: Voice, rate: String, language: Language?) async throws -> (wordTimestamps: [WordTimeStampData], audioData: Data) {
        // Replace with your subscription key and service region
        let speechKey = "Fp11D0CAMjjAcf03VNqe2IsKfqycenIKcrAm4uGV8RSiaqMX15NWJQQJ99AKACYeBjFXJ3w3AAAYACOG6Orb"
        let serviceRegion = "eastus"

        do {
            // Initialize speech configuration
            let speechConfig = try SPXSpeechConfiguration(subscription: speechKey, region: serviceRegion)
            speechConfig.requestWordLevelTimestamps()
//            speechConfig.setServicePropertyTo("explicit", byName: "punctuation", using: .uriQueryParameter)
            speechConfig.outputFormat = .detailed
            speechConfig.setSpeechSynthesisOutputFormat(.riff16Khz16BitMonoPcm) // Use a format compatible with AVAudioPlayer
            speechConfig.speechSynthesisVoiceName = voice.speechSynthesisVoiceName
            speechConfig.speechSynthesisLanguage = language?.speechCode

            // Create a speech synthesizer
            let synthesizer = try SPXSpeechSynthesizer(speechConfiguration: speechConfig, audioConfiguration: nil)

            // Create an array to hold words, timestamps, and offsets
            var wordTimestamps: [WordTimeStampData] = []
            let wordTimestampsQueue = DispatchQueue(label: "WordTimestampsQueue")

            // Add a handler for the word boundary event
            var index = -1
            var sentenceIndex = -1
            let sentenceMarker = "✓"
            synthesizer.addSynthesisWordBoundaryEventHandler { (synthesizer, event) in
                // Extract the audio offset (in ticks of 100 nanoseconds)
                let audioTimeInSeconds = Double(event.audioOffset) / 10_000_000.0

                var word = event.text
                    .replacingOccurrences(of: "\n", with: "") // Most TTS often add \n
                    .replacingOccurrences(of: "                ", with: "") // Korean TTS often adds these spaces, which desyncs words

                if language == .mandarinChinese || language == .japanese {
                    word = word.replacingOccurrences(of: " ", with: "")
                } else {
                    word = word + " "
                }
                
                wordTimestampsQueue.sync {

                    if word.contains(sentenceMarker) {
                        sentenceIndex += 1
                        word = word.replacingOccurrences(of: sentenceMarker, with: "")
                    }

                    if var newTimestamp = wordTimestamps[safe: index] {
                        newTimestamp.duration = audioTimeInSeconds - newTimestamp.time - 0.0001
                        let listOfPrefixes = [
                            "“",
                            "”",
                            "«",
                            "»",
                            "»",
                            "「",
                            "」",
                            "\""
                        ]

                        for prefix in listOfPrefixes {
                            word = word.replacingOccurrences(of: prefix, with: "")
                        }
                        wordTimestamps[index] = newTimestamp
                    }
                    wordTimestamps.append(.init(word: word,
                                                time: audioTimeInSeconds,
                                                duration: event.duration,
                                                indexInList: index,
                                                sentenceIndex: sentenceIndex,
                                                wordPosition: .middle))

                    index += 1
                }
            }

            // Generate the SSML text with the specified rate
            var ssml = """
            <speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="https://www.w3.org/2001/mstts" xml:lang="zh-CN">
            <voice name="\(voice.speechSynthesisVoiceName)">
            """
            // TODO: Update to be able to speak male characters as male voice, storyteller as female, and female characters as same female voice
            for (_, sentence) in chapter.sentences.enumerated() {
                let splitSentence = splitSpeechAndNonSpeech(from: sentence.translation)
                for (index, sentenceSection) in splitSentence.enumerated() {
                    // TODO: Update styleDegree to also be generated with each sentence
                    let isSpeech = speechCharacters.firstIndex(where: { sentenceSection.contains($0)} ) != nil
                    let speechStyle = isSpeech ? SpeechStyle.gentle : voice.defaultSpeechStyle

                    let sentenceSsml = """
                <mstts:express-as style="\(speechStyle.ssmlName)">
                    <prosody rate="\(rate)">
                        \(index == 0 ? sentenceMarker : "")\(sentenceSection)
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
            if speechCharacters.contains(String(character)) {
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

        return results
    }

}

enum WordPosition: Codable {
    case first, middle, last
}
