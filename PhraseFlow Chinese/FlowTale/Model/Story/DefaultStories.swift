//
//  DefaultStories.swift
//  FlowTale
//
//  Created by Claude on 14/03/2025.
//

import Foundation

// A class to manage default stories that come bundled with the app
class DefaultStoryManager {
    
    // Singleton instance
    static let shared = DefaultStoryManager()
    private init() {}
    
    private let fileManager = FileManager.default
    
    // Returns URL for the app's document directory
    private var documentsDirectory: URL? {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    // Returns URL for the app's bundle directory
    private var bundleDirectory: URL? {
        return Bundle.main.resourceURL
    }
    
    // MARK: - Save a story as a default story file
    
    /// Saves a story to the app bundle or to a temporary location that can be copied to the app bundle
    /// - Parameter story: A story object to save as a default example
    /// - Returns: The URL where the story was saved
    @discardableResult
    func saveStoryAsDefault(_ story: Story) -> URL? {
        // Create a copy of the story and mark it as a default story
        var storyCopy = story
        storyCopy.isDefaultStory = true
        
        // Create a unique filename based on the language and date
        let languageKey = storyCopy.language.key.lowercased()
        let filename = "default_story_\(languageKey)_\(storyCopy.id.uuidString).json"
        
        // In debug builds, we'll save to the documents directory for easy access
        #if DEBUG
        guard let docsURL = documentsDirectory?.appendingPathComponent(filename) else {
            print("⚠️ Failed to create URL for default story")
            return nil
        }
        
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
        #else
        // In production builds, this function won't actually save anything
        // since users can't modify the app bundle
        print("This function is only for development. Add default stories to the app bundle manually.")
        return nil
        #endif
    }
    
    // MARK: - Load default stories
    
    /// Loads default stories from the app bundle
    /// - Returns: An array of Story objects that were included in the app bundle
    func loadDefaultStories() -> [Story] {
        guard let bundleURL = bundleDirectory else {
            return []
        }
        
        // Look for files that match our default story naming pattern
        do {
            let bundleContents = try fileManager.contentsOfDirectory(at: bundleURL, includingPropertiesForKeys: nil)
            let defaultStoryFiles = bundleContents.filter { 
                $0.lastPathComponent.hasPrefix("default_story_") && 
                $0.pathExtension == "json" 
            }
            
            var defaultStories: [Story] = []
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            for fileURL in defaultStoryFiles {
                do {
                    let data = try Data(contentsOf: fileURL)
                    let story = try decoder.decode(Story.self, from: data)
                    defaultStories.append(story)
                } catch {
                    print("Failed to decode default story at \(fileURL): \(error)")
                }
            }
            
            return defaultStories
        } catch {
            print("Failed to read bundle directory: \(error)")
            return []
        }
    }
    
    /// Loads a default story for a specific language if one exists
    /// - Parameter language: The language to look for
    /// - Returns: A Story object if one exists for the language, nil otherwise
    func loadDefaultStory(for language: Language) -> Story? {
        let defaultStories = loadDefaultStories()
        return defaultStories.first { $0.language == language }
    }
    
    // MARK: - Check if default stories should be added
    
    /// Checks if default stories should be added to the user's stories
    /// - Parameter existingStories: The user's existing stories
    /// - Returns: True if default stories should be added
    func shouldAddDefaultStories(existingStories: [Story]) -> Bool {
        // Only add default stories if the user has no stories yet
        return existingStories.isEmpty
    }
    
    /// Adds default stories to the existing stories array
    /// - Parameter existingStories: The user's existing stories
    /// - Returns: An array including both existing and default stories
    func addDefaultStoriesToArray(_ existingStories: [Story]) -> [Story] {
        // If the user already has stories, don't add defaults
        if !shouldAddDefaultStories(existingStories: existingStories) {
            return existingStories
        }
        
        // Load default stories and add them to the array
        let defaultStories = loadDefaultStories()
        return existingStories + defaultStories
    }
}

// Extension on Story to make it conform to DefaultStory protocol
extension Story: DefaultStory {
    func encodeForStorage() -> Data? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        do {
            return try encoder.encode(self)
        } catch {
            print("Failed to encode story: \(error)")
            return nil
        }
    }
}