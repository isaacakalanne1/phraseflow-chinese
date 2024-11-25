//
//  DefinitionView.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 25/10/2024.
//

import SwiftUI

struct DefinitionView: View {
    @EnvironmentObject var store: FastChineseStore

    var body: some View {
        VStack(spacing: 5) {
            Text(LocalizedString.definitionOf(store.state.definitionState.tappedWord?.word ?? "..."))
                .greyBackground()
            HStack {
                ScrollView(.vertical) {
                    Text(store.state.viewState.readerDisplayType == .defining ? LocalizedString.defining : (store.state.definitionState.currentDefinition?.definition ?? ""))
                        .foregroundColor(store.state.definitionState.currentDefinition == nil ? .gray : .black)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                }
                if let word = store.state.definitionState.tappedWord {
                    VStack {
                        Button {
                            store.dispatch(.playWord(word))
                        } label: {
                            Image(systemName: "speaker.circle.fill")
                                .resizable()
                        }
                        .frame(width: 40, height: 40)
                        Button {
                            store.dispatch(.defineCharacter(word, shouldForce: true))
                        } label: {
                            Image(systemName: "repeat.circle.fill")
                                .resizable()
                        }
                        .frame(width: 40, height: 40)
                    }
                }

            }
        }
        .fontWeight(.light)
        .id(store.state.viewState.definitionViewId)
    }
}
