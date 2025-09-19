//
//  LoadingState+Arrange.swift
//  Loading
//
//  Created by Isaac Akalanne on 19/09/2025.
//

import Loading

public extension LoadingState {
    static var arrange: LoadingState {
        arrange()
    }
    
    static func arrange(
        loadingStatus: LoadingStatus = .none
    ) -> LoadingState {
        .init(loadingStatus: loadingStatus)
    }
}
