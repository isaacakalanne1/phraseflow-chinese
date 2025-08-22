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
    @EnvironmentObject var store: StoryStore
    
    var isPlayingAudio: Bool {
        store.state.isPlayingChapterAudio
    }

    var body: some View {
        Button {
            if isPlayingAudio {
                store.dispatch(.pauseChapter)
            } else {
                if let currentSpokenWord = store.state.currentChapter?.currentSpokenWord {
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
            .font(FTFont.flowTaleBodyLarge())
            .foregroundColor(FTColor.primary)
            .frame(width: 60, height: 60)
            .background(
                Circle()
                    .fill(FTColor.background)
                    .overlay(Circle().strokeBorder(FTColor.accent, lineWidth: 2))
                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
            )
    }
    
    private func updatePlayTime() async {
        let playbackTime = store.environment.audioEnvironment.audioPlayer.chapterAudioPlayer.currentTime().seconds
        store.dispatch(.setPlaybackTime(playbackTime))
        try? await Task.sleep(for: .seconds(0.1))
        if store.state.isPlayingChapterAudio {
            await updatePlayTime()
        }
    }
}
