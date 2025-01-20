//
//  DefinitionView.swift
//  FlowTale
//
//  Created by iakalann on 25/10/2024.
//

import SwiftUI

struct DefinitionView: View {
    @EnvironmentObject var store: FlowTaleStore

    var body: some View {
        VStack(spacing: 5) {
            Text(LocalizedString.definitionOf(store.state.definitionState.tappedWord?.word ?? "..."))
                .greyBackground()
            HStack {
                if store.state.viewState.isDefining {
                    ProgressView()
                        .frame(maxWidth: .infinity,
                               maxHeight: .infinity,
                               alignment: .center)
                } else {
                    Group {
                        if let definition = store.state.definitionState.currentDefinition {
                            ScrollView(.vertical) {
                                VStack(alignment: .leading) {
                                    HStack(alignment: .top) {
                                        Text("✏️ " + definition.detail.definition)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Text("🗣️ " + definition.detail.pronunciation)
                                    }
                                    Text("🌎 " + definition.detail.definitionInContextOfSentence)
                                }
                            }
                        } else {
                            Text(LocalizedString.tapAWordToDefineIt)
                        }
                    }
                    .foregroundColor(FlowTaleColor.primary)
                    .frame(maxWidth: .infinity,
                           maxHeight: .infinity,
                           alignment: .topLeading)
                    if let word = store.state.definitionState.tappedWord {
                        VStack {
                            Button {
                                store.dispatch(.playWord(word, story: store.state.storyState.currentStory))
                            } label: {
                                SystemImageView(.speaker)
                            }
                            Button {
                                store.dispatch(.defineCharacter(word, shouldForce: true))
                            } label: {
                                SystemImageView(._repeat)
                            }
                        }
                    }
                }
            }
        }
        .fontWeight(.light)
        .id(store.state.viewState.definitionViewId)
    }
}
