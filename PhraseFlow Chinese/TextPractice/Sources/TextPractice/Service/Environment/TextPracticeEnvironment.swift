//
//  TextPracticeEnvironment.swift
//  TextPractice
//
//  Created by Isaac Akalanne on 02/09/2025.
//

import Combine
import TextGeneration
import Study

public struct TextPracticeEnvironment: TextPracticeEnvironmentProtocol {
    public var chapterSubject: CurrentValueSubject<TextGeneration.Chapter?, Never>
    
    public var definitionsSubject: CurrentValueSubject<[Study.Definition]?, Never>
    
    public func setChapter(_ chapter: Chapter?) {
        chapterSubject.send(chapter)
    }
    
    public func addDefinitions(_ definitions: [Definition]) {
        definitionsSubject.send(definitions)
    }
    
    public init() {
        chapterSubject = .init(nil)
        definitionsSubject = .init(nil)
    }
}
