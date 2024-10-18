//
//  FastChineseDataStore.swift
//  FastChinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation

enum FastChineseDataStoreError: Error {
    case failedToCreateUrl
    case failedToSaveAudio
    case failedToSaveData
    case failedToLoadChapter
    case failedToDecodeSentences
}

protocol FastChineseDataStoreProtocol {
    func loadStories() throws -> [Story]
    func saveStory(_ story: Story) throws
    func unsaveStory(_ story: Story) throws
}

class FastChineseDataStore: FastChineseDataStoreProtocol {

    let allStoriesKey = "allStoriesKey"
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first

    init() {
        UserDefaults.standard.removeObject(forKey: allStoriesKey)
    }

    func loadStories() throws -> [Story] {
        guard let fileURL = documentsDirectory?.appendingPathComponent("userData.json") else {
            throw FastChineseDataStoreError.failedToCreateUrl
        }
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let stories = try decoder.decode([Story].self, from: data)
            return stories
        } catch {
            throw FastChineseDataStoreError.failedToDecodeSentences
        }
    }

    func saveStory(_ story: Story) throws {
        var allStories: [Story]
        if let stories = try? loadStories() {
            allStories = stories
            allStories.removeAll(where: { $0.storyOverview == story.storyOverview })
            if allStories.isEmpty {
                allStories = [story]
            } else {
                allStories.append(story)
            }
        } else {
            allStories = [story]
        }

        try saveStories(allStories)
    }

    func unsaveStory(_ story: Story) throws {
        if var stories = try? loadStories() {
            stories.removeAll(where: { $0.storyOverview == story.storyOverview })
            try saveStories(stories)
        }
    }

    private func saveStories(_ stories: [Story]) throws {
        guard let fileURL = documentsDirectory?.appendingPathComponent("userData.json") else {
            throw FastChineseDataStoreError.failedToCreateUrl
        }
        let encoder = JSONEncoder()
        do {
            let encodedData = try encoder.encode(stories)
            try encodedData.write(to: fileURL)
        } catch {
            throw FastChineseDataStoreError.failedToSaveData
        }
    }
}
