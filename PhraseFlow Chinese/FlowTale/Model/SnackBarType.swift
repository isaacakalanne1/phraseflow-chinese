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
    case failedToWriteChapter(Story)

    var text: String {
        switch self {
        case .writingChapter:
            "Writing chapter"
        case .chapterReady:
            "Chapter ready"
        case .failedToWriteChapter:
            "Failed to write chapter. Tap to retry"
        }
    }

    var showDuration: Double? {
        switch self {
        case .writingChapter:
            nil
        case .chapterReady:
            3
        case .failedToWriteChapter:
            4
        }
    }

    @ViewBuilder
    var iconView: some View {
        switch self {
        case .writingChapter:
            ProgressView()
        case .chapterReady:
            Text("✅")
        case .failedToWriteChapter:
            Text("🔁")
        }
    }

    func action(store: FlowTaleStore) {
        switch self {
        case .writingChapter,
                .chapterReady:
            break
        case .failedToWriteChapter(let story):
            store.dispatch(.continueStory(story: story))
        }
    }
}
