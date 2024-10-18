//
//  FastChineseDataStore.swift
//  FastChinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation

enum FastChineseDataStoreError: Error {
    case failedToSaveAudio
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

    func loadStories() throws -> [Story] {
        do {
            guard let savedData = UserDefaults.standard.data(forKey: allStoriesKey) else {
                throw FastChineseDataStoreError.failedToLoadChapter
            }
            return try JSONDecoder().decode([Story].self, from: savedData)
        } catch {
            throw FastChineseDataStoreError.failedToDecodeSentences
        }
    }

    func saveStory(_ story: Story) throws {
        var allStories: [Story]
        if let savedData = UserDefaults.standard.data(forKey: allStoriesKey) {
            allStories = try JSONDecoder().decode([Story].self, from: savedData)
            allStories.append(story)
        } else {
            allStories = [story]
        }
        do {
            let encodedData = try JSONEncoder().encode(allStories)
            UserDefaults.standard.set(encodedData, forKey: allStoriesKey)
        } catch {
            throw FastChineseDataStoreError.failedToDecodeSentences
        }
    }

    func unsaveStory(_ story: Story) throws {
        guard let savedData = UserDefaults.standard.data(forKey: allStoriesKey) else {
            throw FastChineseDataStoreError.failedToLoadChapter
        }
        do {
            var allStories = try JSONDecoder().decode([Story].self, from: savedData)
            allStories.removeAll(where: { $0 == story })
            let encodedData = try JSONEncoder().encode(allStories)
            UserDefaults.standard.set(encodedData, forKey: allStoriesKey)
        } catch {
            throw FastChineseDataStoreError.failedToDecodeSentences
        }
    }
}
