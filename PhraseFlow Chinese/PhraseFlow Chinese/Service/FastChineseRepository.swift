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
    func getCreateStoryRequestData(story: Story?, voice: Voice, difficulty: Difficulty) -> CreateStoryRequestData
}

class FastChineseRepository: FastChineseRepositoryProtocol {

    private let speechCharacters = [
        "“",
        "”",
        "\"",
        "''"
    ]

    init() { }

    func getCreateStoryRequestData(story: Story?, voice: Voice, difficulty: Difficulty) -> CreateStoryRequestData {
        let initialPrompt = getStoryGenerationGuide(voice: voice, difficulty: difficulty)
        let mainPrompt: String
        if let story,
           !story.chapters.isEmpty {
            mainPrompt = """
                This is the story so far:
                \(story.chapters.reduce("") { $0 + "\n\n" + $1.passage })

                Write an engaging, compelling next chapter of this story.
            """
        } else {
            mainPrompt = """
                Write an engaging, compelling first chapter of a story in this setting:
                \(StorySetting.allCases.randomElement()?.title ?? "Medieval")
            """
        }
        return .init(initialPrompt: initialPrompt, mainPrompt: mainPrompt, story: story)
    }

    private func getStoryGenerationGuide(voice: Voice, difficulty: Difficulty) -> String {
        """
        You are the an award-winning Mandarin Chinese novelist. Write a chapter from an engaging Mandarin novel. Use Mandarin Chinese names in the story.

        Start each chapter with "Chapter 1", "Chapter 2", etc, in Mandarin Chinese.

        Use the " character for speech marks.

        In the JSON, provide both the Mandarin sentence and the translated English sentence.

        In the JSON:
        - latestStorySummary: This is a brief summary of the story so far in English. This summary is of the story which happens before the new part of the story you write.
        - mandarin: The story sentence written in Mandarin Chinese.
        - englishTranslation: The story sentence written in English.

        - speechRole: This matches the speaker of the speaker of the sentence.
        The speechRole should be either "male", "female", or "narrator".
        Only use the above speechRoles, never create your own.

        Write a Mandarin chinese story with controversial characters. That is, each character in the story will have some positive aspects, and some aspects which the reader is unsure whether they should side or not. Do not explicitly mention "ah, is this right? la di dah", simply have this be a core element of the story.
        Everything emotional in the story should be insinuated. Lean heavily on "show, not tell" for how characters are feeling, and how events are unfolding.
        Don't have the story be overly positive, and don't have characters randomly, tritely affirm "with x's help, they knew they could succeed!", "with x, they felt stronger from their support" etc, please stop doing this. You are an author, not a moralist lecturer. Write a compelling, engaging, turbulent story, with highs and lows that can each span several chapters.
        Only use Mandarin Chinese characters in the Mandarin section of the JSON. Never include English characters or words in the Mandarin section of the JSON.

        Below are some extra details:

        The story should be written at a specific difficulty level, from a scale of 1 to 10, which will be specified below.
        1 is absolute beginner Mandarin Chinese, the most absolute basic words and vocabulary, very short sentences, very simple grammar and sentence structure.
        10 is absolute professional Mandarin Chinese, with highly advanced grammar, vocabulary, and sentence structures.
        Any numbers between are a linear transition between the above specified minimum and maximum.

        Based on the above scale of 1 to \(difficulty.maxIntValue), write a story with the below difficulty level.
        DIFFICULTY LEVEL: \(difficulty.intValue)

        The Chapter length itself should still always be long, for all difficulty levels.
        """
        // Using the above guidelines, write a story in the style of George R R Martin.
    }

    func synthesizeSpeech(_ chapter: Chapter, voice: Voice, rate: String) async throws -> (wordTimestamps: [WordTimeStampData], audioData: Data) {
        // Replace with your subscription key and service region
        let speechKey = "Fp11D0CAMjjAcf03VNqe2IsKfqycenIKcrAm4uGV8RSiaqMX15NWJQQJ99AKACYeBjFXJ3w3AAAYACOG6Orb"
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
                    let isSpeech = speechCharacters.firstIndex(where: { sentenceSection.contains($0)} ) != nil
                    let speechRole = isSpeech ? sentence.speechRole : voice.defaultSpeechRole
                    let speechStyle = isSpeech ? SpeechStyle.gentle : voice.defaultSpeechStyle

                    let sentenceSsml = """
                <mstts:express-as role="\(speechRole.ssmlName)" style="\(speechStyle.ssmlName)" styledegree="1">
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
