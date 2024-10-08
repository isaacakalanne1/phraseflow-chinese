//
//  FastChineseDataStore.swift
//  PhraseFlow Chinese
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
    func loadChapter(info: ChapterGenerationInfo, chapterIndex: Int) throws -> Chapter
    func saveChapter(_ chapter: Chapter) throws
    func unsaveChapter(_ chapter: Chapter)
    func saveAudioToTempFile(fileName: String, data: Data) throws -> URL
}

class FastChineseDataStore: FastChineseDataStoreProtocol {

    func loadChapter(info: ChapterGenerationInfo, chapterIndex: Int) throws -> Chapter {
        do {
            guard let savedData = UserDefaults.standard.data(forKey: "Chapter \(chapterIndex), \(info.storyOverview)") else {
                throw FastChineseDataStoreError.failedToLoadChapter
            }
            let sentences = try JSONDecoder().decode([Sentence].self, from: savedData)
            return Chapter(sentences: sentences, index: chapterIndex, info: info)
        } catch {
            throw FastChineseDataStoreError.failedToDecodeSentences
        }
    }

    func saveChapter(_ chapter: Chapter) throws {
        let encodedData = try JSONEncoder().encode(chapter.sentences)
        UserDefaults.standard.set(encodedData, forKey: "Chapter \(chapter.index), \(chapter.info.storyOverview)")
    }

    func unsaveChapter(_ chapter: Chapter) {
        UserDefaults.standard.removeObject(forKey: "Chapter \(chapter.index), \(chapter.info.storyOverview)")
    }

    func saveAudioToTempFile(fileName: String, data: Data) throws -> URL {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(fileName).wav")
        do {
            try data.write(to: tempURL)
        } catch {
            throw FastChineseDataStoreError.failedToSaveAudio
        }
        return tempURL
    }
}
