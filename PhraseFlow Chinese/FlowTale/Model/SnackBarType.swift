//
//  SnackBarType.swift
//  FlowTale
//
//  Created by iakalann on 27/12/2024.
//

import SwiftUI

enum SnackBarType {
    case writingChapter
    case chapterReady
    case subscribed
    case failedToWriteChapter(Story)
    case passedModeration
    case didNotPassModeration

    var text: String {
        switch self {
        case .writingChapter:
            "Writing chapter."
        case .chapterReady:
            "Chapter ready."
        case .failedToWriteChapter:
            "Failed to write chapter. Tap to retry."
        case .subscribed:
            "Subscription complete. Unlimited chapters now available."
        case .passedModeration:
            "Custom story added"
        case .didNotPassModeration:
            "Your story did not meet our AI provider's usage policies."
        }
    }

    var showDuration: Double? {
        switch self {
        case .writingChapter:
            nil
        case .chapterReady,
                .failedToWriteChapter,
                .subscribed,
                .passedModeration,
                .didNotPassModeration:
            4
        }
    }

    @ViewBuilder
    var iconView: some View {
        switch self {
        case .writingChapter:
            Text("✏️")
        case .chapterReady,
                .subscribed,
                .passedModeration:
            Text("✅")
        case .failedToWriteChapter:
            Text("🔁")
        case .didNotPassModeration:
            Text("⚠️")
        }
    }

    func action(store: FlowTaleStore) {
        switch self {
        case .writingChapter,
                .chapterReady,
                .subscribed,
                .passedModeration,
                .didNotPassModeration:
            break
        case .failedToWriteChapter(let story):
            store.dispatch(.continueStory(story: story))
        }
    }

    var isError: Bool {
        switch self {
        case .writingChapter,
                .chapterReady,
                .subscribed,
                .didNotPassModeration:
            return false
        case .failedToWriteChapter,
                .passedModeration:
            return true
        }
    }

    var backgroundColor: Color {
        isError ? FlowTaleColor.error : FlowTaleColor.accent
    }

    var sound: AppSound {
        isError ? .errorSnackbar : .snackbar
    }
}
