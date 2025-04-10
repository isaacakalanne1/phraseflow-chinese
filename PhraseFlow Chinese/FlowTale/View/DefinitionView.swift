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
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(FlowTaleColor.primary)
                            Text(definition.detail.pronunciation)
                                .font(.body)
                                .italic()
                                .foregroundColor(FlowTaleColor.accent)
                        }

                        Text(definition.detail.definition)
                            .font(.body)
                            .padding(.horizontal, 4)

                        Divider()

                        Text(definition.detail.definitionInContextOfSentence)
                            .font(.body)
                            .multilineTextAlignment(.leading)
                            .frame(maxHeight: .infinity)
                    }
                    .padding()
                }
            } else if store.state.viewState.isDefining {
                // Loading state when no definition is available yet
                VStack {
                    Text("🔍 \(LocalizedString.loading)")
                        .font(.subheadline)
                        .foregroundColor(FlowTaleColor.secondary)
                    ProgressView()
                        .padding()
                }
            } else {
                // No definition selected state
                VStack {
                    HStack(spacing: 8) {
                        Image(systemName: "hand.tap")
                            .font(.system(size: 24))
                            .foregroundColor(FlowTaleColor.secondary)
                        Text("👆")
                            .font(.system(size: 24))
                    }
                    .padding(.bottom, 10)
                    
                    Text(LocalizedString.tapAWordToDefineIt)
                        .font(.subheadline)
                        .foregroundColor(FlowTaleColor.secondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .id(store.state.viewState.definitionViewId)
    }
}
