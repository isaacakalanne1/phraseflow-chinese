//
//  GenderTests.swift
//  Settings
//
//  Created by Isaac Akalanne on 20/09/2025.
//

import Localization
import Testing
@testable import Settings

final class GenderTests {
    
    @Test
    func gender_male() throws {
        let gender = Gender.male
        
        #expect(gender.rawValue == "male")
        #expect(gender.title == LocalizedString.male)
        #expect(gender.hashValue == Gender.male.hashValue)
    }
    
    @Test
    func gender_female() throws {
        let gender = Gender.female
        
        #expect(gender.rawValue == "female")
        #expect(gender.title == LocalizedString.female)
        #expect(gender.hashValue == Gender.female.hashValue)
    }
}
