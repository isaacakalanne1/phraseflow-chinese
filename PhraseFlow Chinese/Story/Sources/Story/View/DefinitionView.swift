//
//  DefinitionView.swift
//  FlowTale
//
//  Created by iakalann on 25/10/2024.
//

import SwiftUI
import FTFont
import FTColor

struct DefinitionView: View {
    @EnvironmentObject var store: FlowTaleStore
    let definition: Definition?

    var body: some View {
        VStack(spacing: 10) {
            if let definition {
                if store.state.viewState.isDefining {
                    ProgressView()
                } else {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 6) {
                            Text(definition.timestampData.word)
                                .font(FTFont.flowTaleHeader())
                                .fontWeight(.bold)
                                .foregroundColor(FTColor.primary)
                            Text(definition.detail.pronunciation)
                                .font(FTFont.flowTaleBodyMedium())
                                .italic()
                                .foregroundColor(FTColor.accent)
                        }

                        Text(definition.detail.definition)
                            .font(FTFont.flowTaleBodyMedium())
                            .padding(.horizontal, 4)

                        Divider()

                        Text(definition.detail.definitionInContextOfSentence)
                            .font(FTFont.flowTaleBodyMedium())
                            .multilineTextAlignment(.leading)
                            .frame(maxHeight: .infinity)
                    }
                    .padding()
                }
            } else if store.state.viewState.isDefining {
                // Loading state when no definition is available yet
                VStack {
                    Text("🔍 \(LocalizedString.loading)")
                        .font(FTFont.flowTaleSecondaryHeader())
                        .foregroundColor(FTColor.secondary)
                    ProgressView()
                        .padding()
                }
            } else {
                VStack {
                    HStack(spacing: 8) {
                        Image(systemName: "hand.tap")
                            .foregroundColor(FTColor.secondary)
                        Text("👆")
                    }
                    .font(FTFont.flowTaleBodyMedium())
                    .padding(.bottom, 10)
                    
                    Text(LocalizedString.tapAWordToDefineIt)
                        .font(FTFont.flowTaleSecondaryHeader())
                        .foregroundColor(FTColor.secondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .id(store.state.viewState.definitionViewId)
    }
}
