//
//  MusicVolumeTests.swift
//  Audio
//
//  Created by Isaac Akalanne on 22/09/2025.
//

import Testing
@testable import Audio

class MusicVolumeTests {
    
    @Test
    func normal() {
        let volume = MusicVolume.normal
        #expect(volume.float == 0.5)
    }
    
    @Test
    func quiet() {
        let volume = MusicVolume.quiet
        #expect(volume.float == 0.15)
    }
}

