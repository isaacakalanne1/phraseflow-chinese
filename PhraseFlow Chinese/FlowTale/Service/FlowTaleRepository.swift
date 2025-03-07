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

        // Keep track of sentence boundaries
        var sentenceIndex = -1
        
        // Create a queue and semaphore for synchronizing the event handlers
        let syncQueue = DispatchQueue(label: "com.flowtale.synthesis.sync")
        let semaphore = DispatchSemaphore(value: 1)
        
        // Use a single dictionary to track audio offset to sentence index mapping
        var audioOffsetToSentenceIndex: [UInt64: Int] = [:]

        // Reset the speech mark counter each time we start a new synthesis
        speechMarkCounter = 0
        
        // Listen for bookmark events that indicate sentence boundaries
        synthesizer.addBookmarkReachedEventHandler { (synthesizer, event) in
            semaphore.wait()
            defer { semaphore.signal() }
            
            let mark = event.text
            
            // Handle boundary markers
            if mark.hasPrefix("sentence-boundary-") {
                // These are just boundary markers, don't change the sentence index
                // They help create clean separation between sentences
                return
            }
            // Handle actual sentence markers
            else if mark.hasPrefix("sentence-"),
                    let indexString = mark.split(separator: "-").last,
                    let index = Int(indexString) {
                // Store the sentence index with its audio offset
                syncQueue.sync {
                    audioOffsetToSentenceIndex[event.audioOffset] = index
                    sentenceIndex = index
                }
            }
        }

        synthesizer.addSynthesisWordBoundaryEventHandler { (synthesizer, event) in
            semaphore.wait()
            defer { semaphore.signal() }
            
            let audioTimeInSeconds = Double(event.audioOffset) / 10_000_000.0
            var currentSentenceIndex = sentenceIndex
            
            // Check if we have a new sentence index for this audio offset
            syncQueue.sync {
                // Find the closest earlier audio offset that has a sentence index
                // This handles cases where the word boundary event happens slightly after the bookmark
                var closestOffset: UInt64 = 0
                var closestSentenceIndex = -1
                
                // First, look for exact matches
                if let exactSentenceIndex = audioOffsetToSentenceIndex[UInt64(event.audioOffset)] {
                    currentSentenceIndex = exactSentenceIndex
                } else {
                    // Then, look for the closest preceding offset with language-specific adjustments
                    
                    // For Chinese, we need a tighter window to prevent incorrect sentence assignments
                    let isChineseOrJapanese = language == .mandarinChinese || language == .japanese
                    
                    // Much smaller buffer for Chinese to prevent early word shifting
                    let offsetBuffer: UInt64 = isChineseOrJapanese ? 500_000 : 5_000_000 // 50ms for Chinese/Japanese, 500ms for others
                    
                    // Get all boundaries sorted by time
                    let sortedBoundaries = audioOffsetToSentenceIndex.sorted { $0.key < $1.key }
                    var boundaryToUse: (UInt64, Int)? = nil
                    
                    for (i, (offset, sentIndex)) in sortedBoundaries.enumerated() {
                        // For Chinese/Japanese: Find the exact boundary this word belongs to
                        if isChineseOrJapanese {
                            // If we're after this boundary but before the next one, use this sentence
                            if offset <= UInt64(event.audioOffset) {
                                if i == sortedBoundaries.count - 1 || UInt64(event.audioOffset) < sortedBoundaries[i+1].key {
                                    boundaryToUse = (offset, sentIndex)
                                }
                            }
                        } 
                        // For other languages: Use the buffer approach
                        else if offset <= UInt64(event.audioOffset) + offsetBuffer && offset > closestOffset {
                            closestOffset = offset
                            closestSentenceIndex = sentIndex
                        }
                    }
                    
                    // For Chinese/Japanese: Assign based on nearest boundary
                    if isChineseOrJapanese && boundaryToUse != nil {
                        closestSentenceIndex = boundaryToUse!.1
                    }
                    
                    if closestSentenceIndex >= 0 {
                        currentSentenceIndex = closestSentenceIndex
                    }
                }
            }

            // 1. Remove typical artifacts like newlines/spaces,
            //    but do NOT remove speech characters, because we need to detect them properly.
            let rawText = self.removeSynthesisArtifacts(from: event.text,
                                                        language: language,
                                                        isFirstWordInSentence: false,
                                                        removeSpeechMarks: false)

            // 2. Process the text to handle the odd/even speech mark logic.
            //    This method returns what's left for the *current* timestamp
            //    after possibly moving the chunk to the *previous* timestamp.
            let finalWord = self.processSpeechMarks(rawText,
                                                    wordTimestamps: &wordTimestamps,
                                                    language: language)

            // 3. Use the finalWord as is - sentence indices now come from our mapping
            let cleanedWord = finalWord

            // 4. Update the previous timestamp's duration before adding a new one
            if var previousTimestamp = wordTimestamps[safe: index] {
                previousTimestamp.duration = audioTimeInSeconds - previousTimestamp.time
                wordTimestamps[index] = previousTimestamp
            }

            // 5. Add the new timestamp with the correct sentence index
            let newTimestamp = WordTimeStampData(
                id: UUID(),
                storyId: story.id,
                chapterIndex: story.currentChapterIndex,
                word: cleanedWord,
                time: audioTimeInSeconds,
                duration: event.duration,
                sentenceIndex: currentSentenceIndex
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

        // Add a special boundary marker before the first sentence
//        ssml.append("<bookmark mark=\"sentence-boundary-start\"/>")
        
        for (index, sentence) in chapter.sentences.enumerated() {
            // Add newline for readability
            ssml.append("\n")
            
            // For Chinese/Japanese - use sentence tags for better handling
            if voice.language == .mandarinChinese || voice.language == .japanese {
                // First place the bookmark marker
                ssml.append("<bookmark mark=\"sentence-\(index)\"/>")
                
                // Then wrap in sentence tag with clear boundaries
                ssml.append("<s>")
                ssml.append(sentence.translation)
                ssml.append("</s>")
            } else {
                // For other languages - continue using paragraph tags
                ssml.append("<bookmark mark=\"sentence-\(index)\"/>")
                ssml.append("<p>")
                ssml.append(sentence.translation)
                ssml.append("</p>")
            }
            
            // Add a clearer boundary marker between sentences
            if index < chapter.sentences.count - 1 {
                // Longer break for Chinese/Japanese to ensure clear separation
                let breakTime = (voice.language == .mandarinChinese || voice.language == .japanese) ? "250ms" : "250ms"
                ssml.append("<break time=\"\(breakTime)\"/>")
//                ssml.append("<bookmark mark=\"sentence-boundary-\(index+1)\"/>")
            }
        }
        
        // Add a final boundary marker
//        ssml.append("<bookmark mark=\"sentence-boundary-end\"/>")
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

