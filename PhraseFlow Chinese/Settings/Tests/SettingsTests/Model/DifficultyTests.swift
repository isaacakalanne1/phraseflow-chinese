//
//  DifficultyTests.swift
//  Settings
//
//  Created by Isaac Akalanne on 19/09/2025.
//

import Testing
import UIKit
@testable import Settings

final class DifficultyTests {
    
    @Test
    func difficulty_beginner() throws {
        let difficulty = Difficulty.beginner
        
        #expect(difficulty.index == 0)
        #expect(difficulty.thumbnail == UIImage(named: "Difficulty-Beginner"))
        #expect(!difficulty.title.isEmpty)
        #expect(difficulty.vocabularyPrompt == "Write using simple language and simple sentences.")
        #expect(difficulty.hashValue == Difficulty.beginner.hashValue)
        
        let data = try JSONEncoder().encode(difficulty)
        let decodedDifficulty = try JSONDecoder().decode(Difficulty.self, from: data)
        #expect(decodedDifficulty == .beginner)
    }
    
    @Test
    func difficulty_intermediate() throws {
        let difficulty = Difficulty.intermediate
        
        #expect(difficulty.index == 1)
        #expect(difficulty.thumbnail == UIImage(named: "Difficulty-Intermediate"))
        #expect(!difficulty.title.isEmpty)
        #expect(difficulty.vocabularyPrompt == "Write using simple sentences.")
        #expect(difficulty.hashValue == Difficulty.intermediate.hashValue)
        
        let data = try JSONEncoder().encode(difficulty)
        let decodedDifficulty = try JSONDecoder().decode(Difficulty.self, from: data)
        #expect(decodedDifficulty == .intermediate)
    }
    
    @Test
    func difficulty_advanced() throws {
        let difficulty = Difficulty.advanced
        
        #expect(difficulty.index == 2)
        #expect(difficulty.thumbnail == UIImage(named: "Difficulty-Advanced"))
        #expect(!difficulty.title.isEmpty)
        #expect(difficulty.vocabularyPrompt == "Write using simple language.")
        #expect(difficulty.hashValue == Difficulty.advanced.hashValue)
        
        let data = try JSONEncoder().encode(difficulty)
        let decodedDifficulty = try JSONDecoder().decode(Difficulty.self, from: data)
        #expect(decodedDifficulty == .advanced)
    }
    
    @Test
    func difficulty_expert() throws {
        let difficulty = Difficulty.expert
        
        #expect(difficulty.index == 3)
        #expect(difficulty.thumbnail == UIImage(named: "Difficulty-Expert"))
        #expect(!difficulty.title.isEmpty)
        #expect(difficulty.vocabularyPrompt == "")
        #expect(difficulty.hashValue == Difficulty.expert.hashValue)
        
        let data = try JSONEncoder().encode(difficulty)
        let decodedDifficulty = try JSONDecoder().decode(Difficulty.self, from: data)
        #expect(decodedDifficulty == .expert)
    }
    
    @Test
    func difficulty_allCases() throws {
        let allCases = Difficulty.allCases
        
        #expect(allCases.count == 4)
        #expect(allCases[0] == .beginner)
        #expect(allCases[1] == .intermediate)
        #expect(allCases[2] == .advanced)
        #expect(allCases[3] == .expert)
    }
    
    @Test
    func difficulty_equatable() throws {
        let beginner1 = Difficulty.beginner
        let beginner2 = Difficulty.beginner
        let expert = Difficulty.expert
        
        #expect(beginner1 == beginner2)
        #expect(beginner1 != expert)
    }
}
