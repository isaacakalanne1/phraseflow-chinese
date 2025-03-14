//
//  FlowTaleStore.swift
//  FlowTale
//
//  Created by iakalann on 10/09/2024.
//

import Foundation
import ReduxKit
import AVKit

typealias FlowTaleStore = Store<FlowTaleState, FlowTaleAction, FlowTaleEnvironmentProtocol>

// Extension to add convenience methods for default stories
extension FlowTaleStore {
    /// Saves the current story as a default story that can be included in the app bundle
    func saveCurrentStoryAsDefault() -> URL? {
        guard let currentStory = self.state.storyState.currentStory else {
            print("No current story to save as default")
            return nil
        }
        
        // Save the current story as a default story
        return saveStoryAsDefault(currentStory)
    }
    
    /// Saves a specific story as a default story
    func saveStoryAsDefault(_ story: Story) -> URL? {
        // Create a copy of the story and mark it as a default story
        var storyCopy = story
        storyCopy.isDefaultStory = true
        
        // Create a unique filename based on the language and date
        let languageKey = storyCopy.language.key.lowercased()
        let filename = "default_story_\(languageKey)_\(storyCopy.id.uuidString).json"
        
        // In debug builds, we'll save to the documents directory for easy access
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("⚠️ Failed to get documents directory")
            return nil
        }
        
        let docsURL = documentsDirectory.appendingPathComponent(filename)
        
        // Encode the story
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        do {
            let data = try encoder.encode(storyCopy)
            try data.write(to: docsURL)
            print("✅ Default story saved to: \(docsURL.path)")
            print("Copy this file to your project's resources to include it in the app bundle")
            return docsURL
        } catch {
            print("⚠️ Failed to save default story: \(error.localizedDescription)")
            return nil
        }
    }
}
