//
//  MusicType.swift
//  FlowTale
//
//  Created by iakalann on 04/01/2025.
//

import Foundation

public enum MusicType: String, CaseIterable, Sendable, Equatable {
    case whispersOfTranquility = "Whispers of Tranquility"
    case whispersOfTheForest = "Whispers of the Forest"
    case whispersOfTheEnchantedGrove = "Whispers of the Enchanted Grove"

    var fileURL: URL? {
        return Bundle.module.url(forResource: rawValue, withExtension: "mp3")
    }
}
