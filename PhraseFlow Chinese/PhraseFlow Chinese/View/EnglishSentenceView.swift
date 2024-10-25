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
        ScrollView(.vertical) {
            Text(store.state.currentSentence?.english ?? "")
                .font(.title3)
                .foregroundColor(.gray)
                .opacity(store.state.isShowingEnglish ? 1 : 0)
        }
    }
}
