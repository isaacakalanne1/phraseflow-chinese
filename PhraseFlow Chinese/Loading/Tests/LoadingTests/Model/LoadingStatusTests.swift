//
//  LoadingStatusTests.swift
//  Loading
//
//  Created by Isaac Akalanne on 20/09/2025.
//

import Testing
@testable import Loading
@testable import LoadingMocks

final class LoadingStatusTests {
    
    @Test
    func none() {
        let status = LoadingStatus.none
        #expect(status.progressInt == -1)
    }
    
    @Test
    func writing() {
        let status = LoadingStatus.writing
        #expect(status.progressInt == 0)
    }
    
    @Test
    func generatingImage() {
        let status = LoadingStatus.generatingImage
        #expect(status.progressInt == 1)
    }
    
    @Test
    func generatingSpeech() {
        let status = LoadingStatus.generatingSpeech
        #expect(status.progressInt == 2)
    }
    
    @Test
    func generatingDefinitions() {
        let status = LoadingStatus.generatingDefinitions
        #expect(status.progressInt == 3)
    }
    
    @Test
    func complete() {
        let status = LoadingStatus.complete
        #expect(status.progressInt == 4)
    }
}
