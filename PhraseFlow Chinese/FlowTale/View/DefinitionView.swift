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
            Text(LocalizedString.definitionOf(store.state.definitionState.currentWord?.word ?? "..."))
                .greyBackground()
            HStack {
                if store.state.viewState.isDefining {
                    ProgressView()
                        .frame(maxWidth: .infinity,
                               maxHeight: .infinity,
                               alignment: .center)
                } else {
                    Group {
                        if let word = store.state.definitionState.currentWord {
                            ScrollView(.vertical) {
                                VStack(alignment: .leading) {
                                    HStack(alignment: .top) {
                                        Text(LocalizedString.studyDefinitionPrefix + (word.definition?.detail.definition ?? ""))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Text(LocalizedString.studyPronunciationPrefix + (word.definition?.detail.pronunciation ?? ""))
                                    }
                                    Text(LocalizedString.studyContextPrefix + (word.definition?.detail.definitionInContextOfSentence ?? ""))
                                }
                                .frame(maxWidth: .infinity,
                                       maxHeight: .infinity,
                                       alignment: .topLeading)
                            }
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
                        } else {
                            Text(LocalizedString.tapAWordToDefineIt)
                                .frame(maxWidth: .infinity,
                                       maxHeight: .infinity,
                                       alignment: .topLeading)
                        }
                    }
                    .foregroundColor(FlowTaleColor.primary)
                }
            }
        }
        .fontWeight(.light)
        .id(store.state.viewState.definitionViewId)
    }
}
