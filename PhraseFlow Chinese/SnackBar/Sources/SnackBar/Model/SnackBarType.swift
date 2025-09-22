//
//  SnackBarType.swift
//  FlowTale
//
//  Created by iakalann on 27/12/2024.
//

import SwiftUI
import FTColor
import Localization

public enum SnackBarType: Equatable, Sendable {
    case welcomeBack
    case deletedCustomStory
    case subscribed
    case failedToSubscribe
    case failedToWriteChapter
    case failedToWriteTranslation
    case moderatingText
    case passedModeration
    case couldNotModerateText
    case didNotPassModeration
    case dailyChapterLimitReached(nextAvailable: String)
    case deviceVolumeZero
    case none

    var text: String {
        switch self {
        case .welcomeBack:
            LocalizedString.welcomeBack
        case .failedToWriteChapter:
            LocalizedString.snackbarFailedWriteChapter
        case .failedToWriteTranslation:
            "Failed to write translation" // TODO: Localize
        case .failedToSubscribe:
            "Failed to subscribe" // TODO: Localize
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
        case let .dailyChapterLimitReached(nextAvailable):
            LocalizedString.snackbarDailyChapterLimitReached(nextAvailable)
        case .deviceVolumeZero:
            LocalizedString.deviceVolumeZero
        case .none:
            ""
        }
    }

    var showDuration: Double {
        switch self {
        case .dailyChapterLimitReached:
            4
        case .deviceVolumeZero:
            5.0
        default:
            2
        }
    }

    var emoji: String {
        switch self {
        case .moderatingText,
                .dailyChapterLimitReached:
            "⌛"
        case .subscribed,
                .passedModeration,
                .deletedCustomStory:
            "✅"
        case .welcomeBack:
            "🔥"
        case .didNotPassModeration,
                .couldNotModerateText,
                .failedToWriteChapter,
                .failedToWriteTranslation,
                .failedToSubscribe:
            "⚠️"
        case .deviceVolumeZero:
            "🔇"
        case .none:
            ""
        }
    }

    var isError: Bool {
        switch self {
        case .failedToWriteChapter,
                .failedToWriteTranslation,
                .failedToSubscribe,
                .didNotPassModeration,
                .couldNotModerateText:
            return true
        default:
            return false
        }
    }

    var backgroundColor: Color {
        isError ? FTColor.error.color : FTColor.accent.color
    }
}
