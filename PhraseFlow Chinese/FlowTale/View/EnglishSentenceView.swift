//
//  EnglishSentenceView.swift
//  FlowTale
//
//  Created by iakalann on 25/10/2024.
//

import SwiftUI

struct EnglishSentenceView: View {
    @EnvironmentObject var store: FlowTaleStore

    var body: some View {
        VStack {
            Text(LocalizedString.translation)
                .greyBackground(isShowing: store.state.settingsState.isShowingEnglish)
            ScrollView(.vertical) {
                Text(store.state.storyState.currentSentence?.original ?? "")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .opacity(store.state.settingsState.isShowingEnglish ? 1 : 0)
            }
        }
        .fontWeight(.light)
        .id(store.state.viewState.translationViewId)
    }
}
