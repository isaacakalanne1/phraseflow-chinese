//
//  StudyRootView.swift
//  Study
//
//  Created by Isaac Akalanne on 22/07/2025.
//

import SwiftUI
import Definition
import Localization
import FTColor
import FTFont
import Story
import AppleIcon

public struct StudyRootView: View {
    private var store: StudyStore
    private let studyWords: [Definition]
    
    public init(studyWords: [Definition]) {
        self.studyWords = studyWords
        let state = StudyState()
        let environment = StudyEnvironment()
        
        store = StudyStore(
            initial: state,
            reducer: studyReducer,
            environment: environment,
            middleware: studyMiddleware,
            subscriber: studySubscriber
        )
    }
    
    public var body: some View {
        StudyView(studyWords: studyWords)
            .environmentObject(store)
    }
}