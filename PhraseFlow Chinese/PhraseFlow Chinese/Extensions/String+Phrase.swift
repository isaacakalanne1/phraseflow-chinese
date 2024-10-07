//
//  String+Phrase.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation

extension String {
    func getPhrases() -> [Sentence] {
        var phrases = [Sentence]()

        // Split the string into lines
        let lines = self.components(separatedBy: .newlines)

        // Parse each line
        for line in lines {
            // Use a regular expression to match quoted fields
            let pattern = #"(?<=^|,)(\"(?:[^\"]|\"\")*\"|[^,]*)"#
            let regex = try? NSRegularExpression(pattern: pattern, options: [])

            if let matches = regex?.matches(in: line, range: NSRange(location: 0, length: line.utf16.count)) {
                var columns = [String]()

                for match in matches {
                    if let range = Range(match.range, in: line) {
                        var column = String(line[range])

                        // Remove enclosing quotes and unescape any double quotes
                        if column.hasPrefix("\"") && column.hasSuffix("\"") {
                            column.removeFirst()
                            column.removeLast()
                            column = column.replacingOccurrences(of: "\"\"", with: "\"")
                        }

                        columns.append(column)
                    }
                }

                // Ensure there are exactly 3 columns: Mandarin, Pinyin, and English
                if columns.count == 3 {
                    let mandarin = columns[0]
                    let pinyin = columns[1]
                    let english = columns[2].trimmingCharacters(in: .whitespacesAndNewlines)
                    let phrase = Sentence(mandarin: mandarin, pinyin: pinyin, english: english)
                    phrases.append(phrase)
                }
            }
        }

        return phrases
    }
}
