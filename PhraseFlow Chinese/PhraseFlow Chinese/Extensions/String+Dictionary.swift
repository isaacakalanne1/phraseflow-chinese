//
//  String+Dictionary.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 13/09/2024.
//

import Foundation

extension String {
    func convertDictionaryToPhrases() -> [String: Phrase] {
        var phraseDictionary = [String: Phrase]()

        let lines = self.components(separatedBy: .newlines)

        for line in lines {
            guard !line.hasPrefix("#"), !line.isEmpty else { continue }

            // Split by space for each line (adjust to handle spaces correctly)
            let components = line.components(separatedBy: " ")

            // The second Mandarin set (after the traditional) should be at index 1 (adjust index based on format)
            if components.count >= 2 {
                let mandarin = components[1]  // The simplified mandarin

                // Extract pinyin and english
                let pinyinAndEnglish = line.components(separatedBy: "/")
                guard pinyinAndEnglish.count >= 2 else { continue }

                let originalPinyin = pinyinAndEnglish[0].components(separatedBy: "[").last?.components(separatedBy: "]").first?.trimmingCharacters(in: .whitespaces)
                let pinyin = originalPinyin?.convertToneNumberToDiacritic()
                let english = pinyinAndEnglish[1].trimmingCharacters(in: .whitespacesAndNewlines)

                // Create Phrase instance
                let phrase = Phrase(mandarin: mandarin, pinyin: pinyin ?? "", english: english, category: .short)

                // Add to dictionary with mandarin as key
                phraseDictionary[mandarin] = phrase
            }
        }

        return phraseDictionary
    }
}
