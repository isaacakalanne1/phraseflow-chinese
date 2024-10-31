//
//  EnglishSentenceView.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 25/10/2024.
//

import SwiftUI

struct EnglishSentenceView: View {
    @EnvironmentObject var store: FastChineseStore

    var body: some View {
        VStack {
            Text("Translation")
                .greyBackground(isShowing: store.state.isShowingEnglish)
            ScrollView(.vertical) {
                Text(store.state.currentSentence?.english ?? "")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .opacity(store.state.isShowingEnglish ? 1 : 0)
            }
        }
        .fontWeight(.light)
    }
}
