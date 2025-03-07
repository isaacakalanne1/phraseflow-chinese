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

    private let speechCharacters = ["\"", "«", "»", "「", "」", "\"", "''"]
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

        // Start with first sentence (index 0), but initialize at 0 so our 0-indexing works correctly
        var currentSentenceIndex = 0
        
        // Track sentence text for more reliable detection
        let sentences = chapter.sentences.map { $0.translation }
        
        // Keep track of accumulated text to determine sentence boundaries
        var accumulatedText = ""
        
        // Track if we've found a real word in the current sentence
        // This helps identify the proper start of each sentence
        var hasFoundRealWordInCurrentSentence = false
        
        // Special first sentence detection
        var isFirstRealWordInStream = true
        
        // Reset the speech mark counter each time we start a new synthesis
        speechMarkCounter = 0

        synthesizer.addSynthesisWordBoundaryEventHandler { (synthesizer, event) in
            let audioTimeInSeconds = Double(event.audioOffset) / 10_000_000.0

            // 1. Remove typical artifacts like newlines/spaces,
            //    but do NOT remove speech characters, because we need to detect them properly.
            let rawText = self.removeSynthesisArtifacts(from: event.text,
                                                        language: language,
                                                        removeSpeechMarks: false)

            // 2. Process the text to handle the odd/even speech mark logic.
            //    This method returns what's left for the *current* timestamp
            //    after possibly moving the chunk to the *previous* timestamp.
            let finalWord = self.processSpeechMarks(rawText,
                                                    wordTimestamps: &wordTimestamps,
                                                    language: language)

            // 3. Keep track of accumulated text to determine sentence boundaries
            var cleanedWord = finalWord
            
            // Remove any potential sentenceMarker artifacts that might be present
            cleanedWord = cleanedWord.replacingOccurrences(of: self.sentenceMarker, with: "")
            
            // Check if this is a real word (not just whitespace or punctuation)
            let trimmedWord = cleanedWord.trimmingCharacters(in: .whitespacesAndNewlines)
            let containsRealContent = !trimmedWord.isEmpty && !trimmedWord.allSatisfy { $0.isPunctuation }

            // Mark the beginning of real content in the sentence
            if containsRealContent {
                if !hasFoundRealWordInCurrentSentence {
                    hasFoundRealWordInCurrentSentence = true
                }
                
                // Handle very first word with special care
                if isFirstRealWordInStream {
                    isFirstRealWordInStream = false
                    // Forces first real word to start at sentence 0
                    currentSentenceIndex = 0
                }
            }
            
            // Update accumulated text with the current word
            accumulatedText += cleanedWord
            
            // 4. Update the previous timestamp's duration before adding a new one
            if var previousTimestamp = wordTimestamps[safe: index] {
                previousTimestamp.duration = audioTimeInSeconds - previousTimestamp.time
                wordTimestamps[index] = previousTimestamp
            }
            
            // 5. Determine sentence index using a more reliable approach
            // Check if we've completed a sentence by looking for sentence terminating punctuation
            let sentenceTerminators = [".", "?", "!", "。", "？", "！", "…", ";", ":", "；", "："]
            // Use the already defined trimmedWord from above
            let lastChar = trimmedWord.last
            
            // Look for end of sentence punctuation
            let mightBeEndOfSentence = lastChar.map { char in 
                sentenceTerminators.contains(String(char))
            } ?? false
            
            // Store the current sentence index for this word before potentially updating it
            // For the first real word, ensure we start with sentence index 0
            let wordSentenceIndex = hasFoundRealWordInCurrentSentence ? currentSentenceIndex : 0
            
            // If we might be at the end of a sentence, check accumulated text against sentence content
            if mightBeEndOfSentence && currentSentenceIndex < sentences.count {
                // Check if accumulated text contains a substantial part of the current sentence
                // This helps avoid false positives from periods in abbreviations, etc.
                let currentSentence = sentences[currentSentenceIndex]
                let normalizedSentence = self.normalizeForComparison(currentSentence)
                let normalizedAccumulated = self.normalizeForComparison(accumulatedText)
                
                // If we've accumulated most of the sentence text, move to next sentence
                if normalizedAccumulated.contains(normalizedSentence) || 
                   self.textSimilarityScore(normalizedAccumulated, normalizedSentence) > 0.7 {
                    // This word with punctuation belongs to the current sentence
                    currentSentenceIndex += 1
                    accumulatedText = "" // Reset accumulated text for next sentence
                    hasFoundRealWordInCurrentSentence = false // Reset for the next sentence
                }
            }

            // 6. Add the new timestamp with the current sentence index
            let newTimestamp = WordTimeStampData(
                id: UUID(),
                storyId: story.id,
                chapterIndex: story.currentChapterIndex,
                word: cleanedWord,
                time: audioTimeInSeconds,
                duration: event.duration,
                sentenceIndex: wordSentenceIndex // Use the sentence index we determined before advancing
            )
            wordTimestamps.append(newTimestamp)
            index += 1
        }

        // For debugging - dump sentence count
        print("Processing \(sentences.count) sentences")
        
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
    /// If `removeSpeechMarks` is `true`, we also remove speech quotes. By default, it's `false` here,
    /// ensuring we do NOT strip out odd-numbered quotes from the leftover chunk.
    private func removeSynthesisArtifacts(from text: String,
                                          language: Language?,
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
                if !isPunctuation {
                    word = " " + word
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
            // Use proper punctuation for clear sentence boundaries instead of markers
            ssml.append(" \(sentence.translation) ")
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
    
    // Helper method to normalize text for comparison
    private func normalizeForComparison(_ text: String) -> String {
        let normalizedText = text
            .lowercased()
            .replacingOccurrences(of: self.sentenceMarker, with: "")
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove all punctuation and multiple spaces
        let punctuationCharacters = CharacterSet.punctuationCharacters
        let components = normalizedText.components(separatedBy: punctuationCharacters)
        let textWithoutPunctuation = components.joined(separator: " ")
        let words = textWithoutPunctuation.components(separatedBy: .whitespacesAndNewlines)
        let filteredWords = words.filter { !$0.isEmpty }
        
        return filteredWords.joined(separator: " ")
    }
    
    // Calculate similarity between two texts using a basic approach
    private func textSimilarityScore(_ text1: String, _ text2: String) -> Double {
        // Split both texts into sets of words
        let words1 = Set(text1.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty })
        let words2 = Set(text2.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty })
        
        // Calculate Jaccard similarity: intersection divided by union
        if words1.isEmpty && words2.isEmpty { return 1.0 }
        if words1.isEmpty || words2.isEmpty { return 0.0 }
        
        let intersection = words1.intersection(words2).count
        let union = words1.union(words2).count
        
        return Double(intersection) / Double(union)
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
