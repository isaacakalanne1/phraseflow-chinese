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

        var newPinyin = ""
        var tone: Int? = nil

        for char in self {
            if let digit = char.wholeNumberValue, 1...5 ~= digit {
                tone = digit - 1  // Set tone value, tone 5 (neutral) will not have a diacritic
            } else {
                newPinyin.append(char)
            }
        }

        if let tone = tone, tone < 4 {  // Only apply diacritic if tone is 1 to 4
            for (index, char) in newPinyin.enumerated() {
                if let toneChars = tones[char] {
                    var pinyinArray = Array(newPinyin)
                    pinyinArray[index] = toneChars[tone]
                    return String(pinyinArray)
                }
            }
        }

        return newPinyin
    }

}
