//
//  WordTimeStampData+Arrange.swift
//  TextGeneration
//
//  Created by Isaac Akalanne on 20/09/2025.
//

import Foundation
import TextGeneration

public extension WordTimeStampData {
    static var arrange: WordTimeStampData {
        .arrange()
    }
    
    static func arrange(
        id: UUID = UUID(),
        word: String = "",
        time: Double = 0,
        duration: Double = 0
    ) -> WordTimeStampData {
        .init(
            id: id,
            word: word,
            time: time,
            duration: duration
        )
    }
}
