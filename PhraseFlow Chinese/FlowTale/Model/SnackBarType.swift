//
//  SnackBarType.swift
//  FlowTale
//
//  Created by iakalann on 27/12/2024.
//

import SwiftUI

enum SnackBarType {
    case welcomeBack
    case writingChapter
    case chapterReady
    case deletedCustomStory
    case subscribed
    case failedToWriteChapter(Story)
    case moderatingText
    case passedModeration
    case couldNotModerateText
    case didNotPassModeration

    var text: String {
        switch self {
        case .welcomeBack:
            "Welcome back"
        case .writingChapter:
            "Writing chapter."
        case .chapterReady:
            "Chapter ready."
        case .failedToWriteChapter:
            "Failed to write chapter. Tap to retry."
        case .couldNotModerateText:
            "Failed to moderate text. Tap to retry."
        case .subscribed:
            "Subscription complete. Unlimited chapters now available."
        case .passedModeration:
            "Custom story added"
        case .moderatingText:
            "Moderating story"
        case .didNotPassModeration:
            "Your story did not meet our AI provider's usage policies."
        case .deletedCustomStory:
            "Deleted custom story"
        }
    }

    var showDuration: Double? {
        switch self {
        case .writingChapter:
            nil
        case .chapterReady,
                .failedToWriteChapter,
                .subscribed,
                .moderatingText,
                .passedModeration,
                .didNotPassModeration,
                .couldNotModerateText,
                .welcomeBack,
                .deletedCustomStory:
            4
        }
    }

    var iconView: some View {
        let emoji: String
        switch self {
        case .writingChapter:
            emoji = "✏️"
        case .moderatingText:
            emoji = "⌛"
        case .chapterReady,
                .subscribed,
                .passedModeration,
                .deletedCustomStory:
            emoji = "✅"
        case .welcomeBack:
            emoji = "🔥"
        case .failedToWriteChapter:
            emoji = "🔁"
        case .didNotPassModeration,
                .couldNotModerateText:
            emoji = "⚠️"
        }
        return Text(emoji)
    }

    func action(store: FlowTaleStore) {
        switch self {
        case .writingChapter,
                .chapterReady,
                .subscribed,
                .moderatingText,
                .passedModeration,
                .didNotPassModeration,
                .welcomeBack,
                .deletedCustomStory:
            break
        case .failedToWriteChapter(let story):
            store.dispatch(.selectTab(.reader, shouldPlaySound: false))
            store.dispatch(.continueStory(story: story))
        case .couldNotModerateText:
            store.dispatch(.updateStorySetting(.customPrompt(store.state.settingsState.customPrompt)))
        }
    }

    var isError: Bool {
        switch self {
        case .writingChapter,
                .chapterReady,
                .subscribed,
                .moderatingText,
                .passedModeration,
                .welcomeBack,
                .deletedCustomStory:
            return false
        case .failedToWriteChapter,
                .didNotPassModeration,
                .couldNotModerateText:
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
