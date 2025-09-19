//
//  LoadingState.swift
//  Loading
//
//  Created by Isaac Akalanne on 19/07/2025.
//

public struct LoadingState: Equatable {
    var loadingStatus: LoadingStatus
    
    public init(
        loadingStatus: LoadingStatus = .none
    ) {
        self.loadingStatus = loadingStatus
    }
}
