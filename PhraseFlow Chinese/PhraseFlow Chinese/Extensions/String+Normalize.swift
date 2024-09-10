//
//  String+Normalize.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation

extension String {
    var normalized: String {
        self
            .replacingOccurrences(of: "?", with: "？")
            .replacingOccurrences(of: ",", with: "，")

            .replacingOccurrences(of: "!", with: "")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: "！", with: "")
            .replacingOccurrences(of: "。", with: "")
    }
}
