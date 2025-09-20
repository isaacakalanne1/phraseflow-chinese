//
//  StorySettingTests.swift
//  Settings
//
//  Created by Isaac Akalanne on 20/09/2025.
//

import Testing
import UIKit
@testable import Settings

final class StorySettingTests {
    
    @Test
    func storySetting_random() throws {
        let setting = StorySetting.random
        
        #expect(setting.title == "Random story")
        #expect(setting.prompt == nil)
        #expect(setting.thumbnail == UIImage(named: "StoryPrompt-Random"))
    }
    
    @Test
    func storySetting_customPrompt() throws {
        let customPrompt = "A story about dragons"
        let setting = StorySetting.customPrompt(customPrompt)
        
        #expect(setting.title == "Custom story (A story about dragons)")
        #expect(setting.prompt == "A story about dragons")
        #expect(setting.thumbnail == UIImage(named: "StoryPrompt-Create"))
    }
    
    @Test
    func storySetting_customPrompt_empty() throws {
        let setting = StorySetting.customPrompt("")
        
        #expect(setting.title == "Custom story ()")
        #expect(setting.prompt == "")
        #expect(setting.thumbnail == UIImage(named: "StoryPrompt-Create"))
    }
    
    @Test
    func storySetting_customPrompt_longText() throws {
        let longPrompt = "A very long story prompt that contains many words and goes on for quite a while to test how the system handles lengthy prompts"
        let setting = StorySetting.customPrompt(longPrompt)
        
        #expect(setting.title == "Custom story (\(longPrompt))")
        #expect(setting.prompt == longPrompt)
        #expect(setting.thumbnail == UIImage(named: "StoryPrompt-Create"))
    }
    
    @Test
    func storySetting_equatable() throws {
        let random1 = StorySetting.random
        let random2 = StorySetting.random
        let custom1 = StorySetting.customPrompt("Story 1")
        let custom2 = StorySetting.customPrompt("Story 1")
        let custom3 = StorySetting.customPrompt("Story 2")
        
        #expect(random1 == random2)
        #expect(custom1 == custom2)
        #expect(custom1 != custom3)
        #expect(random1 != custom1)
    }
    
    @Test
    func storySetting_codable() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let randomSetting = StorySetting.random
        let randomData = try encoder.encode(randomSetting)
        let decodedRandom = try decoder.decode(StorySetting.self, from: randomData)
        #expect(randomSetting == decodedRandom)
        
        let customSetting = StorySetting.customPrompt("Test prompt")
        let customData = try encoder.encode(customSetting)
        let decodedCustom = try decoder.decode(StorySetting.self, from: customData)
        #expect(customSetting == decodedCustom)
    }
}