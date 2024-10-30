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
            HStack(spacing: 0) {
                Text("Definition of ")
                Text(store.state.tappedWord?.word ?? "...")
                    .fontWeight(store.state.tappedWord?.word == nil ? .regular : .bold)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(4)
            .background {
                Color.gray.opacity(0.3)
                    .clipShape(
                        .rect(cornerRadius: 5)
                    )
            }
            HStack {
                ScrollView(.vertical) {
                    Text(store.state.viewState == .defining ? "Defining..." : (store.state.currentDefinition?.definition ?? ""))
                        .foregroundColor(store.state.currentDefinition == nil ? .gray : .black)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                }
                if let word = store.state.tappedWord {
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
        .fontWeight(.light)
    }
}
