//
//  TextPracticeDataStoreProtocol.swift
//  TextPractice
//
//  Created by Isaac Akalanne on 02/09/2025.
//

import Foundation
import TextGeneration

public protocol TextPracticeDataStoreProtocol {
    func saveChapter(_ chapter: Chapter) throws
}
