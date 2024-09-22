//
//  String+Diacritic.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 23/09/2024.
//

import Foundation

func convertToneNumberToDiacritic(pinyin: String) -> String {
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

    for char in pinyin {
        if let digit = char.wholeNumberValue, 1...4 ~= digit {
            tone = digit - 1
        } else {
            newPinyin.append(char)
        }
    }

    if let tone = tone {
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
