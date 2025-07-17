//
//  SnackBar.swift
//  FlowTale
//
//  Created by iakalann on 27/12/2024.
//

import Foundation
import SwiftUI

struct SnackBar: View {
    @EnvironmentObject private var store: FlowTaleStore

    var type: SnackBarType {
        store.state.snackBarState.type
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                type.iconView
                Text(type.text)
                    .foregroundStyle(.ftBackground)
            }

            // Only show loading indicators for the writing chapter snackbar
            if case .writingChapter = type {
                HStack(spacing: 10) {
                    progressView(checkIfComplete: .writing)
                    if store.state.viewState.shouldShowImageSpinner {
                        progressView(checkIfComplete: .generatingImage)
                    }
                    progressView(checkIfComplete: .generatingSpeech)
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(type.backgroundColor)
        .foregroundStyle(.ftPrimary)
        .cornerRadius(15)
        .multilineTextAlignment(.center)
        .padding()
        .zIndex(Double.infinity)
        .onTapGesture {
            type.action(store: store)
        }
    }

    @ViewBuilder
    func progressView(checkIfComplete completeState: LoadingState) -> some View {
        Group {
            if store.state.viewState.loadingState.progressInt > completeState.progressInt {
                Text("✅")
            } else if store.state.viewState.loadingState.progressInt == completeState.progressInt {
                ProgressView()
                    .scaleEffect(0.8)
                    .tint(.ftBackground)
            } else {
                Circle()
                    .fill(.ftBackground.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
        .frame(width: 20, height: 20)
    }
}
