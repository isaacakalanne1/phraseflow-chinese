//
//  ActionButtonsView.swift
//  FlowTale
//
//  Created by iakalann on 25/10/2024.
//

import SwiftUI
import FTColor

struct ActionButtonsView: View {
    @EnvironmentObject var store: StoryStore

    var body: some View {
        // Story package should focus on story functionality only
        // Navigation tabs should be handled at the app level
        HStack(spacing: 12) {
            Text("Story Actions Placeholder")
                .foregroundColor(FTColor.primary)
        }
    }
}
