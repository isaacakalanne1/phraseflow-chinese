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
            Text(store.state.currentDefinition?.definition ?? "")
                .font(.body)
                .padding(.top)
        }
    }
}
