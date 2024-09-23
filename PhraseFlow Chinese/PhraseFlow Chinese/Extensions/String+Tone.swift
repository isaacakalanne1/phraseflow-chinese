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

        let tones: [Character: [Character]] = [
            "a": ["ā", "á", "ǎ", "à"],
            "e": ["ē", "é", "ě", "è"],
            "i": ["ī", "í", "ǐ", "ì"],
            "o": ["ō", "ó", "ǒ", "ò"],
            "u": ["ū", "ú", "ǔ", "ù"],
            "ü": ["ǖ", "ǘ", "ǚ", "ǜ"]
        ]

        for word in words {
            guard let toneMarker = word.last,
                  let toneMarkerIndex = Int(String(toneMarker)) else {
                allPinyin += (allPinyin.isEmpty ? word : " " + word)
                continue
            }

            // If tone marker is 5, just remove the tone marker and continue
            if toneMarkerIndex == 5 {
                let neutralToneWord = String(word.dropLast()) // Remove the 5 tone marker
                allPinyin += (allPinyin.isEmpty ? neutralToneWord : " " + neutralToneWord)
                continue
            }

            var foundTone = false
            var newPinyin = ""

            for character in word.dropLast() { // Drop the last character (tone number)
                if let toneList = tones[character], !foundTone {
                    // Apply the correct tone to the character and mark it as found
                    newPinyin += String(toneList[toneMarkerIndex - 1])
                    foundTone = true
                } else {
                    newPinyin += String(character)
                }
            }

            allPinyin += (allPinyin.isEmpty ? newPinyin : " " + newPinyin)
        }

        return allPinyin
    }
}
