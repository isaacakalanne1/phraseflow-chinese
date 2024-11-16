//
//  FastChineseState.swift
//  FastChinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation
import AVKit

struct FastChineseState {
    var currentStory: Story?
    var savedStories: [Story] = []
    var sentenceIndex = 0
    var isShowingCreateStoryScreen = false
    var isShowingSettingsScreen = false
    var isShowingStoryListView = false
    var viewState: ViewState = .normal

    var selectedGenres: [Genre] = []
    var selectedStorySetting: StorySetting?

    var currentPlaybackTime: TimeInterval = 0

    var currentChapter: Chapter? {
        guard let currentStory else {
            return nil
        }
        return currentStory.chapters[safe: currentStory.currentChapterIndex]
    }

    var currentSentence: Sentence? {
        guard let currentChapter else {
            return nil
        }
        return currentChapter.sentences[safe: sentenceIndex]
    }

    var currentChapterAudioData: Data? {
        guard let currentStory else {
            return nil
        }
        return currentStory.chapters[safe: currentStory.currentChapterIndex]?.audioData
    }

    var currentDefinition: Definition?

    var audioPlayer = AVPlayer()
    var timestampData: [WordTimeStampData]? {
        currentChapter?.timestampData
    }

    var definitionViewId = UUID()
    var chapterViewId = UUID()
    var translationViewId = UUID()

    var isPlayingAudio = false
    var settingsState: SettingsState = .init(isShowingPinyin: true,
                                         isShowingDefinition: true,
                                         isShowingEnglish: true,
                                         voice: .xiaomo,
                                         speechSpeed: .normal)

    var currentSpokenWord: WordTimeStampData? {
        timestampData?.last(where: { currentPlaybackTime >= $0.time })
//        guard let word = timestampData?.last(where: { currentPlaybackTime >= $0.time }) else { return nil }
//        if word.time + word.duration < currentPlaybackTime,
//           let index = timestampData?.firstIndex(of: word),
//           let followingWord = timestampData?[safe: index + 1] {
//            return followingWord
//        }
//        return word
    }

    var tappedWord: WordTimeStampData?

    func getSpokenWord(sentenceIndex: Int, characterIndex: Int) -> WordTimeStampData? {
        // Calculate the overall character index
        var totalCharacterIndex = 0
        guard let currentChapter else { return nil }

        for (index, sentence) in currentChapter.sentences.enumerated() {
            let sentenceLength = sentence.mandarin.count

            if index < sentenceIndex {
                // Sum up the lengths of previous sentences
                totalCharacterIndex += sentenceLength
            } else if index == sentenceIndex {
                // Add the characterIndex within the current sentence
                totalCharacterIndex += characterIndex
                break
            } else {
                break
            }
        }

        // Now totalCharacterIndex is the overall index of the character
        // Find the SpokenWord in timestampData that includes this index
        return timestampData?.last(where: { totalCharacterIndex >= $0.textOffset})
    }

    /// Function to create an AVPlayer with a specific time pitch algorithm from audio data
    /// - Parameters:
    ///   - audioData: The audio data in Data format
    ///   - fileExtension: The file extension of the audio data (e.g., "mp3", "m4a")
    /// - Returns: An optional AVPlayer instance
    func createAVPlayer(from audioData: Data, fileExtension: String = "mp3") -> AVPlayer? {
        // 1. Create a temporary file URL
        let tempDirectory = FileManager.default.temporaryDirectory
        let tempFileName = UUID().uuidString + "." + fileExtension
        let tempFileURL = tempDirectory.appendingPathComponent(tempFileName)

        do {
            // 2. Write the audio data to the temporary file
            try audioData.write(to: tempFileURL)

            // 3. Create an AVAsset from the file URL
            let asset = AVAsset(url: tempFileURL)

            // 4. Create an AVPlayerItem from the asset
            let playerItem = AVPlayerItem(asset: asset)

            // 5. Set the audio time pitch algorithm to time domain
            playerItem.audioTimePitchAlgorithm = .timeDomain

            // 6. Initialize the AVPlayer with the player item
            let player = AVPlayer(playerItem: playerItem)

            // Optionally, remove the temporary file after a delay to ensure the player has loaded the asset
            DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
                try? FileManager.default.removeItem(at: tempFileURL)
            }

            return player
        } catch {
            print("Error creating AVPlayer from audio data: \(error)")
            return nil
        }
    }

}
