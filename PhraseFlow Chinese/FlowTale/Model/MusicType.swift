//
//  MusicType.swift
//  FlowTale
//
//  Created by iakalann on 04/01/2025.
//

import Foundation

enum MusicType {
    case whispersOfAnOpenBook, whispersOfTranquility, whispersOfTheForest

    var fileURL: URL? {
        let fileName: String
        switch self {
        case .whispersOfAnOpenBook:
            fileName = "Whispers of an Open Book"
        case .whispersOfTranquility:
            fileName = "Whispers of Tranquility"
        case .whispersOfTheForest:
            fileName = "Whispers of the Forest"
        }
        return Bundle.main.url(forResource: fileName, withExtension: "mp3")
    }
}
