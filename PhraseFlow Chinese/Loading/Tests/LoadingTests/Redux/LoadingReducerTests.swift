//
//  LoadingReducerTests.swift
//  Loading
//
//  Created by Isaac Akalanne on 20/09/2025.
//

import Testing
@testable import Loading
@testable import LoadingMocks

final class LoadingReducerTests {
    
    @Test(arguments: [
        LoadingStatus.complete,
        LoadingStatus.generatingDefinitions,
        LoadingStatus.generatingImage,
        LoadingStatus.generatingSpeech,
        LoadingStatus.none,
        LoadingStatus.writing,
    ])
    func loadAppSettings(loadingStatus: LoadingStatus) async throws {
        let initialState = LoadingState.arrange
        var expectedState = initialState
        expectedState.loadingStatus = loadingStatus

        let newState = loadingReducer(
            .arrange,
            .updateLoadingStatus(loadingStatus)
        )

        #expect(newState == expectedState)
    }
}
