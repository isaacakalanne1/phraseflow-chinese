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
    func loadStory(info: StoryGenerationInfo) throws -> Story
    func saveStory(_ story: Story) throws
    func unsaveStory(_ story: Story)
}

class FastChineseDataStore: FastChineseDataStoreProtocol {

    func loadStory(info: StoryGenerationInfo) throws -> Story {
        do {
            guard let savedData = UserDefaults.standard.data(forKey: info.id.uuidString) else {
                throw FastChineseDataStoreError.failedToLoadChapter
            }
            return try JSONDecoder().decode(Story.self, from: savedData)
        } catch {
            throw FastChineseDataStoreError.failedToDecodeSentences
        }
    }

    func saveStory(_ story: Story) throws {
        let encodedData = try JSONEncoder().encode(story)
        UserDefaults.standard.set(encodedData, forKey: story.info.id.uuidString)
    }

    func unsaveStory(_ story: Story) {
        UserDefaults.standard.removeObject(forKey: story.info.id.uuidString)
    }
}
