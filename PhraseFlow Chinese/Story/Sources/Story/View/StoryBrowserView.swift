//
//  StoryBrowserView.swift
//  Story
//
//  Created by Assistant on 23/07/2025.
//

import SwiftUI
import ReduxKit
import Audio
import Settings
import Study
import Translation
import TextGeneration

public struct StoryBrowserView: View {
    private var store: StoryStore
    
    public init(
        audioEnvironment: AudioEnvironmentProtocol,
        settingsEnvironment: SettingsEnvironmentProtocol,
        studyEnvironment: StudyEnvironmentProtocol,
        translationEnvironment: TranslationEnvironmentProtocol,
        textGenerationService: TextGenerationServicesProtocol,
        storyDataStore: StoryDataStoreProtocol
    ) {
        let state = StoryState()
        let environment = StoryEnvironment(
            audioEnvironment: audioEnvironment,
            settingsEnvironment: settingsEnvironment,
            studyEnvironment: studyEnvironment,
            translationEnvironment: translationEnvironment,
            service: textGenerationService,
            dataStore: storyDataStore
        )
        
        store = StoryStore(
            initial: state,
            reducer: storyReducer,
            environment: environment,
            middleware: storyMiddleware
        )
    }
    
    public var body: some View {
        StoryListView()
            .environmentObject(store)
    }
}