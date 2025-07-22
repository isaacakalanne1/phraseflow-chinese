//
//  SnackBar.swift
//  FlowTale
//
//  Created by iakalann on 27/12/2024.
//

import Foundation
import SwiftUI
import FTColor

struct SnackBar: View {
    @EnvironmentObject private var store: SnackBarStore

    var type: SnackBarType {
        store.state.snackBarState.type
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                type.iconView
                Text(type.text)
                    .foregroundStyle(FTColor.background)
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
        .foregroundStyle(FTColor.primary)
        .cornerRadius(15)
        .multilineTextAlignment(.center)
        .padding()
        .zIndex(Double.infinity)
        .onTapGesture {
            type.action(store: store)
        }
    }

    @ViewBuilder
    func progressView(checkIfComplete completeState: LoadingStatus) -> some View {
        Group {
            if store.state.viewState.loadingState.progressInt > completeState.progressInt {
                Text("✅")
            } else if store.state.viewState.loadingState.progressInt == completeState.progressInt {
                ProgressView()
                    .scaleEffect(0.8)
                    .tint(FTColor.background)
            } else {
                Circle()
                    .fill(FTColor.background.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
        .frame(width: 20, height: 20)
    }
}
