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
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(4)
                .background {
                    if store.state.isShowingEnglish {
                        Color.gray.opacity(0.3)
                            .clipShape(.rect(cornerRadius: 5))
                    }
                }
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
