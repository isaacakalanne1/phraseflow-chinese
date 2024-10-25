//
//  ActionButtonsView.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 25/10/2024.
//

import SwiftUI

struct ActionButtonsView: View {
    @EnvironmentObject var store: FastChineseStore

    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                if let sentence = store.state.currentSentence {
                    if sentence.audioData != nil {
                        store.dispatch(.playAudio(time: nil))
                    } else {
                        store.dispatch(.synthesizeAudio(chapter))
                    }
                }
            }) {
                Image(systemName: "play.circle.fill")
            }

            Spacer()
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
