//
//  ActionButtonsView.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 25/10/2024.
//

import SwiftUI

struct ActionButtonsView: View {
    @EnvironmentObject var store: FastChineseStore
    let chapter: Chapter

    var body: some View {

        HStack(spacing: 20) {
            ActionButton(title: LocalizedString.stories,
                         imageName: "list.bullet") {
                store.dispatch(.updateShowingStoryListView(isShowing: true))
            }
            
            if store.state.viewState.playButtonDisplayType == .loading {
                ActionButton(title: LocalizedString.loading,
                             imageName: "ellipsis.circle") { }
                             .disabled(true)
            } else if chapter.audioData == nil ||
                        store.state.settingsState.voice != chapter.audioVoice ||
                        store.state.settingsState.speechSpeed != chapter.audioSpeed {
                ActionButton(title: LocalizedString.load,
                             imageName: "arrow.down.to.line.circle") {
                    store.dispatch(.synthesizeAudio(chapter,
                                                    voice: store.state.settingsState.voice,
                                                    isForced: false))
                }
            } else {
                if store.state.audioState.isPlayingAudio == true {
                    ActionButton(title: LocalizedString.pause,
                                 imageName: "pause.circle.fill") {
                        store.dispatch(.pauseAudio)
                    }
                } else {
                    ActionButton(title: LocalizedString.play,
                                 imageName: "play.circle") {
                        let timestampData = store.state.storyState.currentChapter?.timestampData
                        let currentSpokenWord = store.state.currentSpokenWord ?? timestampData?.first
                        store.dispatch(.playAudio(time: currentSpokenWord?.time))
                    }
                }
            }

            ActionButton(title: LocalizedString.settings,
                         imageName: "gearshape.fill") {
                store.dispatch(.updateShowingSettings(isShowing: true))
            }
        }
    }
}
