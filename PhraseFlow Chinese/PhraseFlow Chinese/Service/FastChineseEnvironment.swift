//
//  FastChineseEnvironment.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation

protocol FastChineseEnvironmentProtocol {
    func fetchPhrases(gid: String) async throws -> [Phrase]
}

struct FastChineseEnvironment: FastChineseEnvironmentProtocol {
    func fetchPhrases(gid: String) async throws -> [Phrase] {
        let spreadsheetId = "19B3xWuRrTMfpva_IJAyRqGN7Lj3aKlZkZW1N7TwesAE"
        let sheetURL = URL(string: "https://docs.google.com/spreadsheets/d/\(spreadsheetId)/export?format=csv&gid=\(gid)")!

        let (data, response) = try await URLSession.shared.data(from: sheetURL)
        guard let csvString = String(data: data, encoding: .utf8) else {
            return []
        }
        let phrases = csvString.getPhrases()
        return phrases
    }
}
