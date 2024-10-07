//
//  Mode.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 08/09/2024.
//

import Foundation

enum PracticeMode: String, CaseIterable, Equatable {
    case writing
    case reading
    case listening

    var title: String {
        self.rawValue.capitalized
    }
}
