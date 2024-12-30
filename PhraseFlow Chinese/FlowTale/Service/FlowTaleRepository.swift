//
//  FlowTaleRepository.swift
//  FlowTale
//
//  Created by iakalann on 10/09/2024.
//

import Foundation
import MicrosoftCognitiveServicesSpeech
import StoreKit

protocol FlowTaleRepositoryProtocol {
    func synthesizeSpeech(_ chapter: Chapter,
                          story: Story,
                          voice: Voice,
                          speechSpeed: SpeechSpeed,
                          language: Language?) async throws -> (wordTimestamps: [WordTimeStampData],
                                                                audioData: Data)
    func getProducts() async throws -> [Product]
    func purchase(_ product: Product) async throws
}

enum FlowTaleRepositoryError: Error {
    case failedToPurchaseSubscription
}

class FlowTaleRepository: FlowTaleRepositoryProtocol {

    private let speechCharacters = ["“", "”", "«", "»", "»", "「", "」", "\"", "''"]
    let subscriptionKey = "Fp11D0CAMjjAcf03VNqe2IsKfqycenIKcrAm4uGV8RSiaqMX15NWJQQJ99AKACYeBjFXJ3w3AAAYACOG6Orb"
    let region = "eastus"
    let sentenceMarker = "✓"

    init() { }

    func synthesizeSpeech(_ chapter: Chapter,
                          story: Story,
                          voice: Voice,
                          speechSpeed: SpeechSpeed,
                          language: Language?) async throws -> (wordTimestamps: [WordTimeStampData], audioData: Data) {

        let synthesizer: SPXSpeechSynthesizer
        do {
            let speechConfig = try createSpeechConfig(voice: voice)
            synthesizer = try SPXSpeechSynthesizer(speechConfiguration: speechConfig, audioConfiguration: nil)
        } catch {
            throw error
        }

        var wordTimestamps: [WordTimeStampData] = []
        var index = -1
        var sentenceIndex = -1

        synthesizer.addSynthesisWordBoundaryEventHandler { (synthesizer, event) in
            let audioTimeInSeconds = Double(event.audioOffset) / 10_000_000.0
            var word = self.removeSynthesisArtifacts(from: event.text, language: language)

            if word.contains(self.sentenceMarker) {
                sentenceIndex += 1
                word = word.replacingOccurrences(of: self.sentenceMarker, with: "")
            }

            if var previousTimestamp = wordTimestamps[safe: index] {
                previousTimestamp.duration = audioTimeInSeconds - previousTimestamp.time
                wordTimestamps[index] = previousTimestamp
            }

            let newTimestamp = WordTimeStampData(id: UUID(),
                                                 storyId: story.id,
                                                 chapterIndex: story.currentChapterIndex,
                                                 word: word,
                                                 time: audioTimeInSeconds,
                                                 duration: event.duration,
                                                 sentenceIndex: sentenceIndex)
            wordTimestamps.append(newTimestamp)

            index += 1
        }

        let ssml = createSpeechSsml(chapter: chapter, voice: voice, speechSpeed: speechSpeed)

        do {
            let result = try synthesizer.speakSsml(ssml)

            guard result.reason != SPXResultReason.canceled,
                  let audioData = result.audioData else {
                let cancellationDetails = try SPXSpeechSynthesisCancellationDetails(fromCanceledSynthesisResult: result)
                let errorDetails = cancellationDetails.errorDetails ?? "Unknown error"
                throw NSError(domain: "SpeechSynthesis", code: -1, userInfo: [NSLocalizedDescriptionKey: errorDetails])
            }

            return (wordTimestamps, audioData)
        } catch {
            throw error
        }
    }

    private func createSpeechSsml(chapter: Chapter, voice: Voice, speechSpeed: SpeechSpeed) -> String {
        let baseUrl = "http://www.w3.org/2001"
        var ssml = """
        <speak version="1.0" xmlns="\(baseUrl)/10/synthesis" xmlns:mstts="\(baseUrl)/mstts" xml:lang="zh-CN">
        <voice name="\(voice.speechSynthesisVoiceName)">
        """
        for sentence in chapter.sentences {
            for (index, section) in splitSpeechAndNonSpeech(from: sentence.translation).enumerated() {
                let isSpeech = speechCharacters.contains(where: { section.contains($0)} )

                let sentenceSsml = """
                <mstts:express-as style="\(voice.speechStyle(isSpeech: isSpeech).ssmlName)">
                    <prosody rate="\(speechSpeed.rate)">
                        \(index == 0 ? sentenceMarker : "")\(section)
                    </prosody>
                </mstts:express-as>
                """
                ssml.append(sentenceSsml)
            }
        }
        ssml.append("</voice></speak>")
        return ssml
    }

    private func createSpeechConfig(voice: Voice) throws -> SPXSpeechConfiguration {
        let speechConfig = try SPXSpeechConfiguration(subscription: subscriptionKey, region: region)
        speechConfig.requestWordLevelTimestamps()
        speechConfig.outputFormat = .detailed
        speechConfig.setSpeechSynthesisOutputFormat(.riff16Khz16BitMonoPcm)
        speechConfig.speechSynthesisVoiceName = voice.speechSynthesisVoiceName
        return speechConfig
    }

    private func removeSynthesisArtifacts(from text: String, language: Language?) -> String {
        var word = text

        word = word
            .replacingOccurrences(of: "\n", with: "") // Most TTS often add \n
            .replacingOccurrences(of: "                ", with: "") // Korean TTS often adds these spaces

        for speechMark in speechCharacters {
            word = word.replacingOccurrences(of: speechMark, with: "")
        }

        switch language {
        case .mandarinChinese,
                .japanese:
//            word = word.replacingOccurrences(of: " ", with: "") // This code may not be necessary
            break
        default:
            word = word + " "
        }

        return word
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

    func getProducts() async throws -> [Product] {
        return try await Product.products(for: ["com.flowtale.unlimited"])
    }

    func purchase(_ product: Product) async throws {
        do {
            let result = try await product.purchase()
            switch result {
            case let .success(.verified(transaction)):
                // Successful purchase
                await transaction.finish()
                // TODO: Track successful subscription here via AppsFlyer
            case let .success(.unverified(transaction, _)):
                // Successful purchase but transaction/receipt can't be verified
                // Could be a jailbroken phone
                await transaction.finish()
                // TODO: Track successful subscription here via AppsFlyer
            case .pending,
                    .userCancelled:
                // Transaction waiting on SCA (Strong Customer Authentication) or
                // approval from Ask to Buy
                throw FlowTaleRepositoryError.failedToPurchaseSubscription
            @unknown default:
                throw FlowTaleRepositoryError.failedToPurchaseSubscription
            }
        } catch {
            throw FlowTaleRepositoryError.failedToPurchaseSubscription
        }
    }

}
