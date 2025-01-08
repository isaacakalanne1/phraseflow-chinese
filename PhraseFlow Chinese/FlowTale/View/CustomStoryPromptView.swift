//
//  CustomStoryPromptView.swift
//  FlowTale
//
//  Created by iakalann on 05/01/2025.
//

import SwiftUI

struct CustomStoryPromptView: View {
    @EnvironmentObject var store: FlowTaleStore



    var body: some View {
        let customPrompt: Binding<String> = .init {
            store.state.settingsState.customPrompt
        } set: { newValue in
            store.dispatch(.updateCustomPrompt(newValue))
        }

        VStack {
            TextField("Enter your story idea", text: customPrompt)
                  .foregroundColor(FlowTaleColor.primary)
                  .background(FlowTaleColor.secondary)
//                  .multilineTextAlignment(.center)
        }
    }
}
