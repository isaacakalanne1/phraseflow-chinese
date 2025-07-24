//
//  MusicType.swift
//  FlowTale
//
//  Created by iakalann on 04/01/2025.
//

import Foundation

public enum MusicType: String, CaseIterable {
    case whispersOfTranquility = "Whispers of Tranquility"
    case whispersOfTheForest = "Whispers of the Forest"
    case whispersOfTheEnchantedGrove = "Whispers of the Enchanted Grove"

    var fileURL: URL? {
        return Bundle.main.url(forResource: rawValue, withExtension: "mp3")
    }

    static func next(after current: MusicType) -> MusicType {
        let allCases = MusicType.allCases
        guard let currentIndex = allCases.firstIndex(where: { $0 == current }),
              currentIndex + 1 < allCases.count
        else {
            // If it's the last one or not found, return the first one
            return allCases.first!
        }
        return allCases[currentIndex + 1]
    }
}
