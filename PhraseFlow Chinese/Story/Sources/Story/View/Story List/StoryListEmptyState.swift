//
//  StoryListEmptyState.swift
//  FlowTale
//
//  Created by iakalann on 30/05/2025.
//

import SwiftUI
import FTFont
import FTColor
import Localization

struct StoryListEmptyState: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "book.closed")
                .font(FTFont.flowTaleBodyXLarge())
                .foregroundColor(FTColor.accent.opacity(0.6))
            
            Text(LocalizedString.noStoriesYet)
                .font(FTFont.flowTaleSecondaryHeader())
                .foregroundColor(FTColor.primary)
            
            Text(LocalizedString.createYourFirstStory)
                .font(FTFont.flowTaleSecondaryHeader())
                .foregroundColor(FTColor.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}
