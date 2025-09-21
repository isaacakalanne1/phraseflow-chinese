//
//  StoryViewState.swift
//  Story
//
//  Created by Isaac Akalanne on 21/09/2025.
//

import Foundation
import Loading

public struct StoryViewState: Equatable {
    public var loadingState: LoadingStatus? = .complete
    public var isDefining: Bool = false
    public var isWritingChapter: Bool = false
    
    public init(
        loadingState: LoadingStatus? = .complete,
        isDefining: Bool = false,
        isWritingChapter: Bool = false
    ) {
        self.loadingState = loadingState
        self.isDefining = isDefining
        self.isWritingChapter = isWritingChapter
    }
}
