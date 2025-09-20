//
//  LoadingEnvironmentTests.swift
//  Loading
//
//  Created by Isaac Akalanne on 20/09/2025.
//

import Testing
@testable import Loading
@testable import LoadingMocks

final class LoadingEnvironmentTests {
    
    let environment: LoadingEnvironmentProtocol
    
    init() {
        self.environment = LoadingEnvironment()
    }
    
    @Test(arguments: [
        LoadingStatus.none,
        LoadingStatus.writing,
        LoadingStatus.generatingImage,
        LoadingStatus.generatingSpeech,
        LoadingStatus.generatingDefinitions,
        LoadingStatus.complete
    ])
    func updateLoadingStatus(loadingStatus: LoadingStatus) {
        environment.updateLoadingStatus(loadingStatus)
        #expect(environment.loadingStatus.value == loadingStatus)
    }
}
