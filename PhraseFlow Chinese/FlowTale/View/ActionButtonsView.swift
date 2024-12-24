//
//  ActionButtonsView.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 25/10/2024.
//

import SwiftUI

struct ActionButtonsView: View {
    @EnvironmentObject var store: FlowTaleStore
    let chapter: Chapter

    var body: some View {

        HStack(spacing: 20) {
            ActionButton(title: LocalizedString.stories, systemImage: .list) {
                store.dispatch(.updateShowingStoryListView(isShowing: true))
            }
            
            if store.state.viewState.playButtonDisplayType == .loading {
                ActionButton(title: LocalizedString.loading, systemImage: .ellipsis) { }
                             .disabled(true)
            } else if chapter.audioData == nil ||
                        store.state.settingsState.voice != chapter.audioVoice ||
                        store.state.settingsState.speechSpeed != chapter.audioSpeed {
                ActionButton(title: LocalizedString.load, systemImage: .arrowDown) {
                    store.dispatch(.synthesizeAudio(chapter,
                                                    voice: store.state.settingsState.voice,
                                                    isForced: false))
                }
            } else {
                if store.state.audioState.isPlayingAudio == true {
                    ActionButton(title: LocalizedString.pause, systemImage: .pause) {
                        store.dispatch(.pauseAudio)
                    }
                } else {
                    ActionButton(title: LocalizedString.play, systemImage: .play) {
                        let timestampData = store.state.storyState.currentChapter?.timestampData
                        let currentSpokenWord = store.state.currentSpokenWord ?? timestampData?.first
                        store.dispatch(.playAudio(time: currentSpokenWord?.time))
                    }
                }
            }

            ActionButton(title: LocalizedString.subscribe, systemImage: .heart) {
                store.dispatch(.setSubscriptionSheetShowing(true))
            }

            ActionButton(title: LocalizedString.settings, systemImage: .gear) {
                store.dispatch(.updateShowingSettings(isShowing: true))
            }
        }
    }
}
