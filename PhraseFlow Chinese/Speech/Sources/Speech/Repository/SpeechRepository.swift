//
//  FlowTaleRepository.swift
//  FlowTale
//
//  Created by iakalann on 10/09/2024.
//

import Foundation
import MicrosoftCognitiveServicesSpeech
import StoreKit
import TextGeneration
import Settings
import FirebaseFirestore

public class SpeechRepository: SpeechRepositoryProtocol {
    private let db = Firestore.firestore()
    
    public init() {}
    
    private let speechCharacters = ["“", "”", "«", "»", "「", "」", "\"", "''"]
    let region = "eastus"
    let sentenceMarker = "[]"

    private var speechMarkCounter: Int = 0
    
    private func getSpeechKey() async throws -> String {
        do {
            let document = try await db.collection("config").document("api_keys").getDocument()
            
            guard document.exists,
                  let speechKey = document.data()?["speech_key"] as? String,
                  !speechKey.isEmpty else {
                throw NSError(domain: "SpeechRepository", code: 401, userInfo: [NSLocalizedDescriptionKey: "Speech API key not found"])
            }
            
            return speechKey
        } catch {
            throw error
        }
    }

    public func synthesizeSpeech(_ chapter: Chapter,
                                 voice: Voice,
                                 language: Language) async throws -> (Chapter, Int)
    {
        var newChapter = chapter

        let synthesizer: SPXSpeechSynthesizer
        do {
            let speechConfig = try await createSpeechConfig(voice: voice)
            synthesizer = try SPXSpeechSynthesizer(speechConfiguration: speechConfig, audioConfiguration: nil)
        } catch {
            throw error
        }

        var wordTimestamps: [WordTimeStampData] = []

        var index = -1

        var sentenceIndex = -1

        speechMarkCounter = 0

        synthesizer.addSynthesisWordBoundaryEventHandler { _, event in
            let audioTimeInSeconds = Double(event.audioOffset) / 10_000_000.0

            let rawText = self.removeSynthesisArtifacts(from: event.text,
                                                        language: language,
                                                        isFirstWordInSentence: event.text.contains(self.sentenceMarker),
                                                        removeSpeechMarks: false)

            let finalWord = self.processSpeechMarks(rawText,
                                                    wordTimestamps: &wordTimestamps)

            var cleanedWord = finalWord
            if cleanedWord.contains(self.sentenceMarker) {
                sentenceIndex += 1
                cleanedWord = cleanedWord.replacingOccurrences(of: self.sentenceMarker, with: "")
            }

            if wordTimestamps.indices.contains(index) {
                var previousTimestamp = wordTimestamps[index]
                previousTimestamp.duration = audioTimeInSeconds - previousTimestamp.time
                wordTimestamps[index] = previousTimestamp
            }

            let newTimestamp = WordTimeStampData(
                id: UUID(),
                word: cleanedWord,
                time: audioTimeInSeconds,
                duration: event.duration
            )
            wordTimestamps.append(newTimestamp)
            index += 1
            newChapter.sentences[sentenceIndex].timestamps.append(newTimestamp)
        }

        let ssml = createSpeechSsml(chapter: chapter, voice: voice)
        let ssmlCharacterCount = ssml.count

        do {
            let result = try synthesizer.speakSsml(ssml)
            guard result.reason != SPXResultReason.canceled,
                  let audioData = result.audioData
            else {
                let cancellationDetails = try SPXSpeechSynthesisCancellationDetails(fromCanceledSynthesisResult: result)
                let errorDetails = cancellationDetails.errorDetails ?? "Unknown error"
                throw NSError(domain: "SpeechSynthesis", code: -1, userInfo: [NSLocalizedDescriptionKey: errorDetails])
            }

            newChapter.audio = ChapterAudio(data: audioData)
            newChapter.audioVoice = voice
            return (newChapter, ssmlCharacterCount)
        } catch {
            throw error
        }
    }

    private func processSpeechMarks(_ text: String,
                                    wordTimestamps: inout [WordTimeStampData]) -> String
    {
        let speechMarkSet = Set(speechCharacters)

        var chunkBuffer = ""

        for char in text {
            if speechMarkSet.contains(String(char)) {
                speechMarkCounter += 1
                chunkBuffer.append(char)

                if speechMarkCounter % 2 == 0 {
                    if let lastIndex = wordTimestamps.indices.last {
                        wordTimestamps[lastIndex].word += chunkBuffer
                    }
                    chunkBuffer = ""
                }
            } else {
                chunkBuffer.append(char)
            }
        }
        return chunkBuffer
    }

    private func removeSynthesisArtifacts(from text: String,
                                          language: Language?,
                                          isFirstWordInSentence: Bool,
                                          removeSpeechMarks: Bool = false) -> String
    {
        var word = text
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "                ", with: "")

        if removeSpeechMarks {
            for speechMark in speechCharacters {
                word = word.replacingOccurrences(of: speechMark, with: "")
            }
        }

        switch language {
        case .mandarinChinese,
                .japanese:
            word = word.replacingOccurrences(of: " ", with: "")
        default:
            let trimmed = word.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                let lastChar = trimmed.last!
                let isPunctuation = CharacterSet(charactersIn: ".,;:!?。，；：！？…").contains(lastChar.unicodeScalars.first!) && trimmed.count == 1
                if !isPunctuation,
                   !isFirstWordInSentence
                {
                    word = " " + word
                } else if isPunctuation {
                    word = word + " "
                }
            }
        }

        return word
    }

    public func createSpeechSsml(chapter: Chapter,
                                 voice: Voice) -> String
    {
        let baseUrl = "http://www.w3.org/2001"

        var ssml = """
        <speak version="1.0" xmlns="\(baseUrl)/10/synthesis" xmlns:mstts="\(baseUrl)/mstts" xml:lang="\(voice.language.speechCode)"><voice name="\(voice.speechSynthesisVoiceName)">
        """

        for sentence in chapter.sentences {
            ssml.append("\(sentenceMarker)\(sentence.translation) ")
        }

        ssml.append("</voice></speak>")
        return ssml
    }

    private func createSpeechConfig(voice: Voice) async throws -> SPXSpeechConfiguration {
        let speechKey = try await getSpeechKey()
        let speechConfig = try SPXSpeechConfiguration(subscription: speechKey, region: region)
        speechConfig.requestWordLevelTimestamps()
        speechConfig.outputFormat = .detailed
        speechConfig.setSpeechSynthesisOutputFormat(.riff16Khz16BitMonoPcm)
        speechConfig.speechSynthesisVoiceName = voice.speechSynthesisVoiceName
        return speechConfig
    }
}

