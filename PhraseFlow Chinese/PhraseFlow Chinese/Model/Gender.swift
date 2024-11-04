//
//  Gender.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 04/11/2024.
//

import Foundation

enum Gender: String {
    case male, female

    var title: String {
        rawValue.capitalized
    }
}
