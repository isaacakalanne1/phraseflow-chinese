//
//  AudioButton.swift
//  FlowTale
//
//  Created by iakalann on 18/04/2025.
//

import SwiftUI
import FTFont
import FTColor

struct AudioButton: View {
    @EnvironmentObject var store: StoryStore

    var body: some View {
        Button {
            if store.state.audioState.isPlayingAudio {
                store.dispatch(.pauseChapter)
            } else {
                let timestamps = store.state.currentChapter?.currentSentence?.timestamps ?? []
                if let currentSpokenWord = store.state.currentChapter?.currentSpokenWord ?? timestamps.first {
                    store.dispatch(.playChapter(fromWord: currentSpokenWord))
                }
            }
        } label: {
            audioButtonLabel(systemImage: store.state.audioState.isPlayingAudio ? .pause : .play)
        }
    }

    @ViewBuilder
    private func audioButtonLabel(systemImage: SystemImage) -> some View {
        Image(systemName: systemImage.systemName)
            .font(FTFont.flowTaleBodyLarge()) // TODO: Remove if not needed
            .foregroundColor(FTColor.primary)
            .frame(width: 60, height: 60)
            .background(
                Circle()
                    .fill(FTColor.background)
                    .overlay(Circle().strokeBorder(FTColor.accent, lineWidth: 2))
                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
            )
    }
}
