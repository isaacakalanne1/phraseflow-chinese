//
//  MusicTypeTests.swift
//  Audio
//
//  Created by Isaac Akalanne on 22/09/2025.
//

import Testing
@testable import Audio

class MusicTypeTests {
    
    @Test
    func whispersOfTranquility() {
        let music = MusicType.whispersOfTranquility
        #expect(music.rawValue == "Whispers of Tranquility")
        #expect(music.fileURL?.lastPathComponent == "Whispers of Tranquility.mp3")
    }
    
    @Test
    func whispersOfTheForest() {
        let music = MusicType.whispersOfTheForest
        #expect(music.rawValue == "Whispers of the Forest")
        #expect(music.fileURL?.lastPathComponent == "Whispers of the Forest.mp3")
    }
    
    @Test
    func whispersOfTheEnchantedGrove() {
        let music = MusicType.whispersOfTheEnchantedGrove
        #expect(music.rawValue == "Whispers of the Enchanted Grove")
        #expect(music.fileURL?.lastPathComponent == "Whispers of the Enchanted Grove.mp3")
    }
    
    @Test
    func allCases() {
        let allCases = MusicType.allCases
        #expect(allCases.count == 3)
        #expect(allCases.contains(.whispersOfTranquility))
        #expect(allCases.contains(.whispersOfTheForest))
        #expect(allCases.contains(.whispersOfTheEnchantedGrove))
    }
}

