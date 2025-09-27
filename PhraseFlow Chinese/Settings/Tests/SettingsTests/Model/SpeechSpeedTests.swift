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
    func speechSpeed_xslow() throws {
        let speed = SpeechSpeed.xslow
        
        #expect(speed.nextSpeed == .slow)
        #expect(speed.playRate == 0.5)
        #expect(speed.text == "0.5X")
    }
    
    @Test
    func speechSpeed_slow() throws {
        let speed = SpeechSpeed.slow
        
        #expect(speed.nextSpeed == .normal)
        #expect(speed.playRate == 0.75)
        #expect(speed.text == "0.75X")
    }
    
    @Test
    func speechSpeed_normal() throws {
        let speed = SpeechSpeed.normal
        
        #expect(speed.nextSpeed == .fast)
        #expect(speed.playRate == 1)
        #expect(speed.text == "1.0X")
    }
    
    @Test
    func speechSpeed_fast() throws {
        let speed = SpeechSpeed.fast
        
        #expect(speed.nextSpeed == .xfast)
        #expect(speed.playRate == 1.25)
        #expect(speed.text == "1.25X")
    }
    
    @Test
    func speechSpeed_xfast() throws {
        let speed = SpeechSpeed.xfast
        
        #expect(speed.nextSpeed == .xslow)
        #expect(speed.playRate == 1.5)
        #expect(speed.text == "1.5X")
    }
    
    @Test
    func speechSpeed_allCases() throws {
        let allCases = SpeechSpeed.allCases
        
        #expect(allCases.count == 5)
        #expect(allCases.contains(.xslow))
        #expect(allCases.contains(.slow))
        #expect(allCases.contains(.normal))
        #expect(allCases.contains(.fast))
        #expect(allCases.contains(.xfast))
    }
    
    @Test
    func speechSpeed_nextSpeedCycle() throws {
        let xslow = SpeechSpeed.xslow
        let slow = xslow.nextSpeed
        let normal = slow.nextSpeed
        let fast = normal.nextSpeed
        let xfast = fast.nextSpeed
        let backToXSlow = xfast.nextSpeed
        
        #expect(slow == .slow)
        #expect(normal == .normal)
        #expect(fast == .fast)
        #expect(xfast == .xfast)
        #expect(backToXSlow == .xslow)
    }
}
