//
//  StoryListEmptyState.swift
//  FlowTale
//
//  Created by iakalann on 30/05/2025.
//

import SwiftUI

struct StoryListEmptyState: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "book.closed")
                .font(.flowTaleBodyXLarge())
                .foregroundColor(FlowTaleColor.accent.opacity(0.6))
            
            Text(LocalizedString.noStoriesYet)
                .font(.flowtaleSecondaryHeader())
                .foregroundColor(FlowTaleColor.primary)
            
            Text(LocalizedString.createYourFirstStory)
                .font(.flowtaleSecondaryHeader())
                .foregroundColor(FlowTaleColor.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}
