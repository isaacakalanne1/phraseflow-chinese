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
        LanguageMenu(
            selectedLanguage: Binding(
                get: { store.state.settings.language },
                set: { newLanguage in
                    store.dispatch(.updateLanguage(newLanguage))
                }
            ),
            isEnabled: true
        )
    }
}
