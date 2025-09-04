//
//  TextPracticeEnvironmentProtocol.swift
//  TextPractice
//
//  Created by Isaac Akalanne on 02/09/2025.
//

import Combine
import TextGeneration
import Study

public protocol TextPracticeEnvironmentProtocol {
    var chapterSubject: CurrentValueSubject<Chapter?, Never> { get }
    var definitionsSubject: CurrentValueSubject<[Definition]?, Never> { get }
    func setChapter(_ chapter: Chapter?)
    func addDefinitions(_ definitions: [Definition])
}
