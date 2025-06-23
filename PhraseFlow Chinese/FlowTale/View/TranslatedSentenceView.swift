//
//  TranslatedSentenceView.swift
//  FlowTale
//
//  Created by iakalann on 25/10/2024.
//

import SwiftUI

struct TranslatedSentenceView: View {
    @EnvironmentObject var store: FlowTaleStore

    var body: some View {
        VStack(spacing: 8) {
            if store.state.storyState.currentSentence != nil {
                if store.state.settingsState.isShowingEnglish {
                    // Show translation with scroll indicators
                    Text(store.state.storyState.currentSentence?.original ?? "")
                        .font(.body)
                        .foregroundColor(FlowTaleColor.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                } else {
                    // Show hidden state
                    VStack {
                        Image(systemName: "eye.slash")
                            .font(.system(size: 20))
                            .foregroundColor(FlowTaleColor.secondary)
                            .padding(.bottom, 4)
                        
                        Text(LocalizedString.tapRevealToShow)
                            .font(.subheadline)
                            .foregroundColor(FlowTaleColor.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
            } else {
                // No sentence selected state
                VStack {
                    Text("Select a sentence to see the translation")
                        .font(.subheadline)
                        .foregroundColor(FlowTaleColor.secondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}
