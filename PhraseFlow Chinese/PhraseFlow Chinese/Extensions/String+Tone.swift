//
//  String+Tone.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 13/09/2024.
//

import Foundation

extension String {
    func convertToneNumberToDiacritic() -> String {
        var allPinyin = ""
        let words = self.components(separatedBy: " ")
        for word in words {
            var newPinyin = ""
            let tones: [Character: [Character]] = [
                "a": ["ā", "á", "ǎ", "à"],
                "e": ["ē", "é", "ě", "è"],
                "i": ["ī", "í", "ǐ", "ì"],
                "o": ["ō", "ó", "ǒ", "ò"],
                "u": ["ū", "ú", "ǔ", "ù"],
                "ü": ["ǖ", "ǘ", "ǚ", "ǜ"]
            ]
            guard let toneMarker = word.last else { return self }
            let toneMarkerString = String(toneMarker)
            guard let toneMarkerIndex = Int(toneMarkerString) else { return self }
            var characterIndex = 0

            for character in self {
                guard let toneList = tones[character],
                      toneList.count > toneMarkerIndex else {
                    characterIndex += 1
                    continue
                }
                let newTone = String(toneList[toneMarkerIndex])
                newPinyin = word.prefix(characterIndex) + newTone + word.dropFirst(characterIndex)
                break
            }
            if newPinyin.isNotEmpty {
                if allPinyin.isEmpty {
                    allPinyin.append(newPinyin)
                } else {
                    allPinyin.append(" \(newPinyin)")
                }
            }
        }
        return allPinyin
    }

}
