//
//  Mode.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 08/09/2024.
//

import Foundation

enum PracticeMode: CaseIterable, Equatable {
    case writing
    case reading
    case listening

    var title: String {
        switch self {
        case .writing:
            "Writing"
        case .reading:
            "Reading"
        case .listening:
            "Listening"
        }
    }
}
