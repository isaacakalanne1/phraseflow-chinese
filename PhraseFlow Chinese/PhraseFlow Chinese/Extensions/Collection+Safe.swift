//
//  Collection+Safe.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 29/10/2024.
//

import Foundation

extension Collection {
    // Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
