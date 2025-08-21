//
//  LoadingEnvironmentProtocol.swift
//  Loading
//
//  Created by Isaac Akalanne on 19/07/2025.
//

import Foundation
import Combine

public protocol LoadingEnvironmentProtocol {
    var loadingStatus: CurrentValueSubject<LoadingStatus?, Never> { get }
    
    func updateLoadingStatus(_ status: LoadingStatus)
}
