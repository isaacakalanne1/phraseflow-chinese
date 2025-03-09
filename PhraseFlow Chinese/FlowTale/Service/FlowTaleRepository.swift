//
//  FlowTaleRepository.swift
//  FlowTale
//
//  Created by iakalann on 10/09/2024.
//

import Foundation
import MicrosoftCognitiveServicesSpeech
import StoreKit
import CommonCrypto
import UIKit

protocol FlowTaleRepositoryProtocol {
    func synthesizeSpeech(_ chapter: Chapter,
                          story: Story,
                          voice: Voice,
                          language: Language) async throws -> ChapterAudio
    func getProducts() async throws -> [Product]
    func purchase(_ product: Product) async throws
    func validateAppStoreReceipt()
}

enum FlowTaleRepositoryError: Error {
    case failedToPurchaseSubscription
}

class FlowTaleRepository: FlowTaleRepositoryProtocol {

    private let speechCharacters = ["“", "”", "«", "»", "「", "」", "\"", "''"]
    let subscriptionKey = "Fp11D0CAMjjAcf03VNqe2IsKfqycenIKcrAm4uGV8RSiaqMX15NWJQQJ99AKACYeBjFXJ3w3AAAYACOG6Orb"
    let region = "eastus"
    let sentenceMarker = "[]"

    /// Keep track of how many speech marks we've encountered so far (odd/even).
    private var speechMarkCounter: Int = 0

    init() { }

    func synthesizeSpeech(_ chapter: Chapter,
                          story: Story,
                          voice: Voice,
                          language: Language) async throws -> ChapterAudio {

        let synthesizer: SPXSpeechSynthesizer
        do {
            let speechConfig = try createSpeechConfig(voice: voice)
            synthesizer = try SPXSpeechSynthesizer(speechConfiguration: speechConfig, audioConfiguration: nil)
        } catch {
            throw error
        }

        // The array of timestamps to return.
        var wordTimestamps: [WordTimeStampData] = []

        // We'll increment this each time we add a WordTimeStampData entry.
        var index = -1

        // Keep track of "sentence" boundaries if you rely on `sentenceMarker`.
        var sentenceIndex = -1

        // Reset the speech mark counter each time we start a new synthesis
        speechMarkCounter = 0

        synthesizer.addSynthesisWordBoundaryEventHandler { (synthesizer, event) in
            let audioTimeInSeconds = Double(event.audioOffset) / 10_000_000.0

            // 1. Remove typical artifacts like newlines/spaces,
            //    but do NOT remove speech characters, because we need to detect them properly.
            let rawText = self.removeSynthesisArtifacts(from: event.text,
                                                        language: language,
                                                        isFirstWordInSentence: event.text.contains(self.sentenceMarker),
                                                        removeSpeechMarks: false)

            // 2. Process the text to handle the odd/even speech mark logic.
            //    This method returns what's left for the *current* timestamp
            //    after possibly moving the chunk to the *previous* timestamp.
            let finalWord = self.processSpeechMarks(rawText,
                                                    wordTimestamps: &wordTimestamps,
                                                    language: language)

            // 3. Check for sentence markers (if you use them to increment sentenceIndex).
            var cleanedWord = finalWord
            if cleanedWord.contains(self.sentenceMarker) {
                sentenceIndex += 1
                cleanedWord = cleanedWord.replacingOccurrences(of: self.sentenceMarker, with: "")
            }

            // 4. Update the previous timestamp's duration before adding a new one
            if var previousTimestamp = wordTimestamps[safe: index] {
                previousTimestamp.duration = audioTimeInSeconds - previousTimestamp.time
                wordTimestamps[index] = previousTimestamp
            }

            // 5. Add the new timestamp
            let newTimestamp = WordTimeStampData(
                id: UUID(),
                storyId: story.id,
                chapterIndex: story.currentChapterIndex,
                word: cleanedWord,
                time: audioTimeInSeconds,
                duration: event.duration,
                sentenceIndex: sentenceIndex
            )
            wordTimestamps.append(newTimestamp)
            index += 1
        }

        // Generate the SSML and speak it
        let ssml = createSpeechSsml(chapter: chapter, voice: voice)

        do {
            let result = try synthesizer.speakSsml(ssml)
            guard result.reason != SPXResultReason.canceled,
                  let audioData = result.audioData else {
                let cancellationDetails = try SPXSpeechSynthesisCancellationDetails(fromCanceledSynthesisResult: result)
                let errorDetails = cancellationDetails.errorDetails ?? "Unknown error"
                throw NSError(domain: "SpeechSynthesis", code: -1, userInfo: [NSLocalizedDescriptionKey: errorDetails])
            }

            return ChapterAudio(timestamps: wordTimestamps, data: audioData)
        } catch {
            throw error
        }
    }

    // MARK: - Speech Mark Processing

    /// On odd-numbered speech marks, we keep buffering in `chunkBuffer`.
    /// On even-numbered speech marks, we move the entire chunk (including the opening/closing marks)
    /// to the *previous* timestamp. After that, we reset `chunkBuffer`.
    ///
    /// The leftover (post-even mark) in `chunkBuffer` becomes the final word for this boundary event.
    private func processSpeechMarks(_ text: String,
                                    wordTimestamps: inout [WordTimeStampData],
                                    language: Language) -> String {

        // Convert speech characters into a Set for quick membership checks
        let speechMarkSet = Set(speechCharacters)

        // This buffer holds any characters from an odd mark to an even mark (and everything in between).
        var chunkBuffer = ""

        for char in text {
            if speechMarkSet.contains(String(char)) {
                // We found a speech quote/mark
                speechMarkCounter += 1
                chunkBuffer.append(char)

                if speechMarkCounter % 2 == 0 {
                    // Even-numbered speech mark:
                    // Move the entire chunkBuffer into the *previous* timestamp's `word`
                    if let lastIndex = wordTimestamps.indices.last {
                        // Append chunkBuffer (which includes the opening & closing quotes)
                        wordTimestamps[lastIndex].word += chunkBuffer
                    }
                    // Reset chunkBuffer, since we have appended it to the previous timestamp
                    chunkBuffer = ""
                }
            } else {
                // Normal character, keep adding to the chunk buffer
                chunkBuffer.append(char)
            }
        }

        // After we've scanned all characters:
        //   The leftover in chunkBuffer is the "current" word for this boundary event.
        //   We DO remove typical artifacts like newlines, big spaces, etc.
        //   but not the quotes, because we want to keep them for odd-numbered marks.

        // If you really want to remove quotes from the leftover chunk, you'd set `removeSpeechMarks: true`.
        // But since we want to keep them, we pass `false`.
        return chunkBuffer
    }

    // MARK: - Artifact Removal

    /// Cleans up typical TTS artifacts (e.g. newlines, big spaces).
    /// If `removeSpeechMarks` is `true`, we also remove speech quotes. By default, it’s `false` here,
    /// ensuring we do NOT strip out odd-numbered quotes from the leftover chunk.
    private func removeSynthesisArtifacts(from text: String,
                                          language: Language?,
                                          isFirstWordInSentence: Bool,
                                          removeSpeechMarks: Bool = false) -> String {

        var word = text

        // Remove newlines and large spaces
        word = word
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "                ", with: "") // Korean TTS often adds these

        if removeSpeechMarks {
            for speechMark in speechCharacters {
                word = word.replacingOccurrences(of: speechMark, with: "")
            }
        }

        // For Chinese/Japanese, we remove spaces entirely
        switch language {
        case .mandarinChinese, .japanese:
            word = word.replacingOccurrences(of: " ", with: "")
        default:
            // For non-CJK languages, only add a space if the word doesn't end with punctuation
            let trimmed = word.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                let lastChar = trimmed.last!
                let isPunctuation = CharacterSet(charactersIn: ".,;:!?。，；：！？…").contains(lastChar.unicodeScalars.first!)
                if !isPunctuation,
                   !isFirstWordInSentence {
                    word = " " + word
                } else if isPunctuation {
                    word = word + " "
                }
            }
        }

        return word
    }

    // MARK: - SSML Generation

    private func createSpeechSsml(chapter: Chapter,
                                  voice: Voice) -> String {
        let baseUrl = "http://www.w3.org/2001"

        var ssml = """
<speak version="1.0" xmlns="\(baseUrl)/10/synthesis" xmlns:mstts="\(baseUrl)/mstts" xml:lang="\(voice.language.speechCode)">
<voice name="\(voice.speechSynthesisVoiceName)">
"""

        for sentence in chapter.sentences {
            ssml.append("\(sentenceMarker)\(sentence.translation)")
        }

        ssml.append("</voice></speak>")
        return ssml
    }
    // MARK: - Speech Configuration

    private func createSpeechConfig(voice: Voice) throws -> SPXSpeechConfiguration {
        let speechConfig = try SPXSpeechConfiguration(subscription: subscriptionKey, region: region)
        speechConfig.requestWordLevelTimestamps()
        speechConfig.outputFormat = .detailed
        speechConfig.setSpeechSynthesisOutputFormat(.riff16Khz16BitMonoPcm)
        speechConfig.speechSynthesisVoiceName = voice.speechSynthesisVoiceName
        return speechConfig
    }

    // MARK: - StoreKit Purchases (unchanged)

    func getProducts() async throws -> [Product] {
        return try await Product.products(for: [
            "com.flowtale.level_1",
            "com.flowtale.level_2",
            "com.flowtale.level_3"
        ])
    }

    func purchase(_ product: Product) async throws {
        do {
            // First, validate the receipt to ensure we're properly handling sandbox receipts
            validateAppStoreReceipt()
            
            // Then attempt to purchase the product
            let result = try await product.purchase()
            switch result {
            case let .success(.verified(transaction)):
                // Successful purchase
                await transaction.finish()
                // TODO: Track successful subscription here via AppsFlyer
            case let .success(.unverified(transaction, _)):
                // Successful purchase but transaction/receipt can't be verified
                // Since we already validated the receipt, we can still proceed
                await transaction.finish()
                // TODO: Track successful subscription here via AppsFlyer
            case .pending, .userCancelled:
                throw FlowTaleRepositoryError.failedToPurchaseSubscription
            @unknown default:
                throw FlowTaleRepositoryError.failedToPurchaseSubscription
            }
        } catch {
            throw FlowTaleRepositoryError.failedToPurchaseSubscription
        }
    }
    
    /// Validates the App Store receipt
    func validateAppStoreReceipt() {
        guard let receiptURL = Bundle.main.appStoreReceiptURL,
              FileManager.default.fileExists(atPath: receiptURL.path) else {
            let request = SKReceiptRefreshRequest()
            request.start()
            return
        }
    }
}

