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
                switch store.state.viewState.readerDisplayType {
                case .defining:
                    ProgressView()
                        .tint(Color.accentColor)
                        .frame(maxWidth: .infinity,
                               maxHeight: .infinity,
                               alignment: .center)
                default:
                    ScrollView(.vertical) {
                        Text(store.state.definitionState.currentDefinition?.definition ?? "Tap word to define") // TODO: Localize
                            .foregroundColor(store.state.definitionState.currentDefinition == nil ? .gray : .black)
                            .frame(maxWidth: .infinity,
                                   maxHeight: .infinity,
                                   alignment: .leading)
                    }
                    if let word = store.state.definitionState.tappedWord {
                        VStack {
                            Button {
                                store.dispatch(.playWord(word,
                                                         story: store.state.storyState.currentStory))
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
