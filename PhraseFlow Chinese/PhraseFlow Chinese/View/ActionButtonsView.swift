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

        HStack {
            Spacer()

            if chapter.audioData == nil {
                Button(action: {
                    store.dispatch(.synthesizeAudio(chapter))
                }) {
                    Image(systemName: "tray.and.arrow.down.fill")
                }
            } else {
                if store.state.audioPlayer?.isPlaying == true {
                    Button(action: {
                        store.dispatch(.pauseAudio)
                    }) {
                        Image(systemName: "pause.circle.fill")
                    }
                } else {
                    Button(action: {
                        store.dispatch(.playAudio(time: nil))
                    }) {
                        Image(systemName: "play.circle.fill")
                    }
                }
            }

            Button(action: {
                store.dispatch(.updateShowPinyin(!store.state.isShowingPinyin))
            }) {
                Image(systemName: store.state.isShowingPinyin ? "s.circle.fill" : "strikethrough")
                    .frame(width: 50, height: 50)
            }

            Button {
                store.dispatch(.updateShowingCreateStoryScreen(isShowing: true))
            } label: {
                Image(systemName: "plus.rectangle.fill.on.rectangle.fill")
            }

            Button {
                store.dispatch(.updateShowingStoryListView(isShowing: true))
            } label: {
                Image(systemName: "list.bullet.rectangle.portrait.fill")
            }

            Button(action: {
                store.dispatch(.updateShowingSettings(isShowing: true))
            }) {
                Image(systemName: "gearshape.fill")
            }
            Spacer()
        }
        .font(.system(size: 50))
    }
}
