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
        ScrollView(.vertical) {
            Text(store.state.currentDefinition?.definition ?? "Tap a word to see the definition")
                .foregroundStyle(store.state.currentDefinition == nil ? Color.gray : Color.black)
                .font(.body)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.gray, lineWidth: 2)
        )
    }
}
