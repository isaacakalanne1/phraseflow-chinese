//
//  Category.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 17/10/2024.
//

import Foundation

enum Category: String, CaseIterable {
    case romance, adventure, action, drama, suspense, thriller, historical

    var title: String {
        rawValue.capitalized
    }
}
