//
//  ChapterAudio+Arrange.swift
//  TextGeneration
//
//  Created by Isaac Akalanne on 20/09/2025.
//

import Foundation
import TextGeneration

public extension ChapterAudio {
    static var arrange: ChapterAudio {
        .arrange()
    }
    
    static func arrange(
        data: Data = .init()
    ) -> ChapterAudio {
        .init(data: data)
    }
}
