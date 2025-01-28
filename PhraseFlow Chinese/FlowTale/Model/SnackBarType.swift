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
    case dailyChapterLimitReached

    var text: String {
        switch self {
        case .welcomeBack:
            LocalizedString.welcomeBack
        case .writingChapter:
            LocalizedString.writingChapter
        case .chapterReady:
            LocalizedString.chapterReady
        case .failedToWriteChapter:
            LocalizedString.failedToWriteChapter
        case .couldNotModerateText:
            LocalizedString.failedModerateText
        case .subscribed:
            LocalizedString.subscriptionComplete
        case .passedModeration:
            LocalizedString.customStoryAdded
        case .moderatingText:
            LocalizedString.moderatingStory
        case .didNotPassModeration:
            LocalizedString.storyDidNotMeetPolicies
        case .deletedCustomStory:
            LocalizedString.deletedCustomStory
        case .dailyChapterLimitReached:
            "Your daily chapter limit has been reached. Tap here to learn why."
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
                .deletedCustomStory,
                .dailyChapterLimitReached:
            4
        }
    }

    var iconView: some View {
        let emoji: String
        switch self {
        case .writingChapter:
            emoji = "✏️"
        case .moderatingText,
                .dailyChapterLimitReached:
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
                .deletedCustomStory,
                .dailyChapterLimitReached:
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
                .couldNotModerateText,
                .dailyChapterLimitReached:
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
