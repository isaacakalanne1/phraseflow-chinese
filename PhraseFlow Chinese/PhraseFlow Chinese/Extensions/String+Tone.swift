//
//  String+Tone.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 13/09/2024.
//

import Foundation

extension String {
    func convertToneNumberToDiacritic() -> String {
        let tones: [Character: [Character]] = [
            "a": ["ā", "á", "ǎ", "à"],
            "e": ["ē", "é", "ě", "è"],
            "i": ["ī", "í", "ǐ", "ì"],
            "o": ["ō", "ó", "ǒ", "ò"],
            "u": ["ū", "ú", "ǔ", "ù"],
            "ü": ["ǖ", "ǘ", "ǚ", "ǜ"]
        ]
        guard let toneMarker = self.last else { return self }
        let toneMarkerString = String(toneMarker)
        guard let toneMarkerIndex = Int(toneMarkerString) else { return self }
        var characterIndex = 0
        var updatedPinyin = self

        for character in self {
            guard let toneList = tones[character],
                  toneList.count > toneMarkerIndex else { continue }
            let newTone = String(toneList[toneMarkerIndex])
            updatedPinyin = updatedPinyin.prefix(characterIndex) + newTone + updatedPinyin.dropFirst(characterIndex)
            break
        }
        return updatedPinyin
    }

}
