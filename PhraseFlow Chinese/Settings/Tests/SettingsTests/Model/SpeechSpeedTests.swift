//
//  SpeechSpeedTests.swift
//  Settings
//
//  Created by Isaac Akalanne on 20/09/2025.
//

import Localization
import Testing
@testable import Settings

final class SpeechSpeedTests {
    
    @Test
    func speechSpeed_slow() throws {
        let speed = SpeechSpeed.slow
        
        #expect(speed.title == LocalizedString.slow)
        #expect(speed.nextSpeed == .normal)
        #expect(speed.playRate == 0.5)
        #expect(speed.rate == "x-slow")
        #expect(speed.emoji == "🐌")
        #expect(speed.text == "0.5X")
    }
    
    @Test
    func speechSpeed_normal() throws {
        let speed = SpeechSpeed.normal
        
        #expect(speed.title == LocalizedString.normal)
        #expect(speed.nextSpeed == .fast)
        #expect(speed.playRate == 1)
        #expect(speed.rate == "medium")
        #expect(speed.emoji == "🚗")
        #expect(speed.text == "1X")
    }
    
    @Test
    func speechSpeed_fast() throws {
        let speed = SpeechSpeed.fast
        
        #expect(speed.title == LocalizedString.fast)
        #expect(speed.nextSpeed == .slow)
        #expect(speed.playRate == 1.5)
        #expect(speed.rate == "fast")
        #expect(speed.emoji == "🚀")
        #expect(speed.text == "1.5X")
    }
    
    @Test
    func speechSpeed_allCases() throws {
        let allCases = SpeechSpeed.allCases
        
        #expect(allCases.count == 3)
        #expect(allCases.contains(.slow))
        #expect(allCases.contains(.normal))
        #expect(allCases.contains(.fast))
    }
    
    @Test
    func speechSpeed_nextSpeedCycle() throws {
        let slow = SpeechSpeed.slow
        let normal = slow.nextSpeed
        let fast = normal.nextSpeed
        let backToSlow = fast.nextSpeed
        
        #expect(normal == .normal)
        #expect(fast == .fast)
        #expect(backToSlow == .slow)
    }
}