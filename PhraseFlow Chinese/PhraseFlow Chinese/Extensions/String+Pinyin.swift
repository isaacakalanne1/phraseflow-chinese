//
//  String+Pinyin.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 11/09/2024.
//

import Foundation

extension String {
    func extractPhrases() -> [Sentence] {
        var phrases: [Sentence] = []

        let lines = self.split(separator: "\n").filter { !$0.starts(with: "#") && !$0.starts(with: "%") && !$0.isEmpty }

        for line in lines {
            let components = line.components(separatedBy: " /")

            // Ensure we have the right format with Pinyin, Mandarin, and English
            guard components.count >= 2 else { continue }

            // Extract Mandarin and Pinyin parts
            let pinyinMandarin = components[0].components(separatedBy: "] ")
            guard pinyinMandarin.count == 2 else { continue }

            let mandarin = pinyinMandarin[0].components(separatedBy: " [").first ?? ""
            let pinyinRaw = pinyinMandarin[1]

            // Convert pinyin to use diacritics
            let pinyinWithDiacritic = pinyinRaw.convertToneNumberToDiacritic()

            // Extract English translation
            let english = components[1].replacingOccurrences(of: "/", with: "").trimmingCharacters(in: .whitespaces)

            // Create a Phrase object
            let phrase = Sentence(mandarin: mandarin, pinyin: pinyinWithDiacritic, english: english, category: .medium)
            phrases.append(phrase)
        }

        return phrases
    }

}
