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
            if chapter.audioData == nil ||
                store.state.appSettings.voice != chapter.audioVoice ||
                store.state.appSettings.speechSpeed != chapter.audioSpeed {
                ActionButton(title: "Load",
                             imageName: "arrow.down.to.line.circle") {
                    store.dispatch(.synthesizeAudio(chapter,
                                                    voice: store.state.appSettings.voice,
                                                    isForced: false))
                }
            } else {
                if store.state.isPlayingAudio == true {
                    ActionButton(title: "Pause",
                                 imageName: "pause.circle.fill") {
                        store.dispatch(.pauseAudio)
                    }
                } else {
                    ActionButton(title: "Play",
                                 imageName: "play.circle") {
                        let timestampData = store.state.timestampData
                        let currentSpokenWord = store.state.currentSpokenWord ?? timestampData?.first
                        store.dispatch(.playAudio(time: currentSpokenWord?.time))
                    }
                }
            }

            ActionButton(title: "Load",
                         imageName: "arrow.down.to.line.circle") {
                store.dispatch(.synthesizeAudio(chapter,
                                                voice: store.state.appSettings.voice,
                                                isForced: true))
            }

//            ActionButton(title: "Pinyin",
//                         imageName: store.state.appSettings.isShowingPinyin ? "lightbulb.fill" : "lightbulb.slash") {
//                store.dispatch(.updateShowPinyin(!store.state.appSettings.isShowingPinyin))
//            }

            ActionButton(title: "Stories",
                         imageName: "list.bullet") {
                store.dispatch(.updateShowingStoryListView(isShowing: true))
            }

            ActionButton(title: "Settings",
                         imageName: "gearshape.fill") {
                store.dispatch(.updateShowingSettings(isShowing: true))
            }
        }
    }
}
