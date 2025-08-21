//
//  LoadingEnvironment.swift
//  Loading
//
//  Created by Isaac Akalanne on 19/07/2025.
//

import Foundation
import Combine

public struct LoadingEnvironment: LoadingEnvironmentProtocol {
    public var loadingStatus: CurrentValueSubject<LoadingStatus?, Never>
    
    public init() {
        loadingStatus = .init(nil)
    }
    
    public func updateLoadingStatus(_ status: LoadingStatus) {
        loadingStatus.send(status)
    }
}
