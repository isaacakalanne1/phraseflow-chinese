//
//  DefinitionView.swift
//  FlowTale
//
//  Created by iakalann on 25/10/2024.
//

import SwiftUI

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
                                .font(.flowTaleHeader())
                                .fontWeight(.bold)
                                .foregroundColor(FlowTaleColor.primary)
                            Text(definition.detail.pronunciation)
                                .font(.flowTaleBodyMedium())
                                .italic()
                                .foregroundColor(FlowTaleColor.accent)
                        }

                        Text(definition.detail.definition)
                            .font(.flowTaleBodyMedium())
                            .padding(.horizontal, 4)

                        Divider()

                        Text(definition.detail.definitionInContextOfSentence)
                            .font(.flowTaleBodyMedium())
                            .multilineTextAlignment(.leading)
                            .frame(maxHeight: .infinity)
                    }
                    .padding()
                }
            } else if store.state.viewState.isDefining {
                // Loading state when no definition is available yet
                VStack {
                    Text("🔍 \(LocalizedString.loading)")
                        .font(.flowTaleSecondaryHeader())
                        .foregroundColor(FlowTaleColor.secondary)
                    ProgressView()
                        .padding()
                }
            } else {
                VStack {
                    HStack(spacing: 8) {
                        Image(systemName: "hand.tap")
                            .foregroundColor(FlowTaleColor.secondary)
                        Text("👆")
                    }
                    .font(.flowTaleBodyMedium())
                    .padding(.bottom, 10)
                    
                    Text(LocalizedString.tapAWordToDefineIt)
                        .font(.flowTaleSecondaryHeader())
                        .foregroundColor(FlowTaleColor.secondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .id(store.state.viewState.definitionViewId)
    }
}
