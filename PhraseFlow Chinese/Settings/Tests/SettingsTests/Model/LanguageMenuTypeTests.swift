//
//  LanguageTests 2.swift
//  Settings
//
//  Created by Isaac Akalanne on 20/09/2025.
//


import Localization
import Testing
@testable import Settings

final class LanguageMenuTypeTests {
    
    @Test
    func normal() {
        let type = LanguageMenuType.normal
        #expect(type.shouldShowAutoDetect == false)
    }
    
    @Test
    func translationTargetLanguage() {
        let type = LanguageMenuType.translationTargetLanguage
        #expect(type.shouldShowAutoDetect == false)
    }
    
    @Test
    func translationSourceLanguage() {
        let type = LanguageMenuType.translationSourceLanguage
        #expect(type.shouldShowAutoDetect == true)
    }
}
