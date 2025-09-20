//
//  MockLoadingEnvironment.swift
//  Loading
//
//  Created by Isaac Akalanne on 19/09/2025.
//

import Combine
import Loading

enum MockLoadingEnvironmentError: Error {
    case genericError
}

public class MockLoadingEnvironment: LoadingEnvironmentProtocol {
    public var loadingStatus: CurrentValueSubject<LoadingStatus?, Never>
    
    public init(
        loadingStatus: CurrentValueSubject<LoadingStatus?, Never> = .init(nil)
    ) {
        self.loadingStatus = loadingStatus
    }
    
    var updateLoadingStatusSpy: LoadingStatus?
    var updateLoadingStatusCalled = false
    public func updateLoadingStatus(_ status: LoadingStatus) {
        updateLoadingStatusSpy = status
        updateLoadingStatusCalled = true
    }
}
