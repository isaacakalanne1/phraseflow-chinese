//
//  AudioButton.swift
//  FlowTale
//
//  Created by iakalann on 18/04/2025.
//

import SwiftUI
import FTFont
import FTColor
import AppleIcon
import ReduxKit

struct AudioButton: View {
    @EnvironmentObject var store: TextPracticeStore
    
    var isPlayingAudio: Bool {
        store.state.isPlayingChapterAudio
    }
    
    var hasReachedEnd: Bool {
        let allTimestamps = store.state.chapter.sentences.flatMap { $0.timestamps }
        guard let lastWord = allTimestamps.last else { return false }
        let endTime = lastWord.time + lastWord.duration
        return store.state.chapter.currentPlaybackTime >= endTime
    }

    var body: some View {
        Button {
            if isPlayingAudio {
                store.dispatch(.pauseChapter)
            } else {
                if hasReachedEnd,
                   let firstWord = store.state.chapter.sentences.flatMap ({ $0.timestamps }).first,
                   let firstSentence = store.state.chapter.sentences.first {
                    store.dispatch(.setPlaybackTime(firstWord.time))
                    store.dispatch(.updateCurrentSentence(firstSentence))
                    store.dispatch(.playChapter(fromWord: firstWord))
                    Task {
                        // Small delay to ensure state updates
                        try? await Task.sleep(for: .milliseconds(50))
                        await updatePlayTime()
                    }
                } else if let currentSpokenWord = store.state.chapter.currentSpokenWord {
                    store.dispatch(.playChapter(fromWord: currentSpokenWord))
                    Task {
                        await updatePlayTime()
                    }
                }
            }
        } label: {
            audioButtonLabel(systemImage: isPlayingAudio ? .pause : .play)
        }
    }

    @ViewBuilder
    private func audioButtonLabel(systemImage: SystemImage) -> some View {
        Image(systemName: systemImage.systemName)
            .font(FTFont.bodyLarge.font)
            .foregroundColor(FTColor.primary.color)
            .frame(width: 60, height: 60)
            .background(
                Circle()
                    .fill(FTColor.background.color)
                    .overlay(Circle().strokeBorder(FTColor.accent.color, lineWidth: 2))
                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
            )
    }
    
    private func updatePlayTime() async {
        let playbackTime = store.state.chapterAudioPlayer.currentTime().seconds
        store.dispatch(.setPlaybackTime(playbackTime))
        
        // Update current sentence based on playback time
        if let currentWord = store.state.chapter.currentSpokenWord,
           let sentence = store.state.chapter.sentences.first(where: { $0.timestamps.contains { $0.id == currentWord.id } }),
           sentence != store.state.chapter.currentSentence {
            store.dispatch(.updateCurrentSentence(sentence))
        }
        
        // Check if we've reached the end
        let allTimestamps = store.state.chapter.sentences.flatMap { $0.timestamps }
        if let lastWord = allTimestamps.last {
            let endTime = lastWord.time + lastWord.duration
            if playbackTime >= endTime {
                store.dispatch(.pauseChapter)
                return
            }
        }
        
        try? await Task.sleep(for: .seconds(0.1))
        if store.state.isPlayingChapterAudio {
            await updatePlayTime()
        }
    }
}
