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
import Settings
import ReduxKit

struct StoryListEmptyState: View {
    @EnvironmentObject var store: StoryStore
    
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
            
            LanguageMenu(
                selectedLanguage: Binding(
                    get: { store.state.settings.language },
                    set: { newLanguage in
                        var updatedSettings = store.state.settings
                        updatedSettings.language = newLanguage
                        store.dispatch(.saveAppSettings(updatedSettings))
                    }
                ),
                isEnabled: true
            )
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
}
