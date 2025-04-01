//
//  LoadingView.swift
//  FlowTale
//
//  Created by iakalann on 31/12/2024.
//

import SwiftUI

struct LoadingView: View {
    @EnvironmentObject var store: FlowTaleStore

    var body: some View {
        VStack {
            Text(LocalizedString.writingNewChapter)
            HStack {
                progressView(checkIfComplete: .writing)
                progressView(checkIfComplete: .generatingImage)
                progressView(checkIfComplete: .generatingSpeech)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FlowTaleColor.background)
    }

    @ViewBuilder
    func progressView(checkIfComplete completeState: LoadingState) -> some View {
        Group {
            if store.state.viewState.loadingState.progressInt > completeState.progressInt {
                Text("✅")
            } else {
                ProgressView()
            }
        }
        .frame(width: 30, height: 30)
    }
}
