//
//  Sentence+Arrange.swift
//  TextGeneration
//
//  Created by Isaac Akalanne on 20/09/2025.
//

import Foundation
import TextGeneration

public extension Sentence {
    static var arrange: Sentence {
        .arrange()
    }
    
    static func arrange(
        id: UUID = UUID(),
        translation: String = "",
        original: String = "",
        timestamps: [WordTimeStampData] = [.arrange]
    ) -> Sentence {
        .init(
            id: id,
            translation: translation,
            original: original,
            timestamps: timestamps
        )
    }
}
