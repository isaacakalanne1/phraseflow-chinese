//
//  DefinitionState.swift
//  FlowTale
//
//  Created by iakalann on 16/11/2024.
//

import Foundation

struct DefinitionState {
    var tappedWord: WordTimeStampData?
    var currentDefinition: Definition?
    var definitions: [Definition]

    init(tappedWord: WordTimeStampData? = nil,
         currentDefinition: Definition? = nil,
         definitions: [Definition] = []) {
        self.tappedWord = tappedWord
        self.currentDefinition = currentDefinition
        self.definitions = definitions
    }

    func definition(of word: String, in sentence: Sentence) -> Definition? {
        definitions.first(where: { $0.timestampData.word == word && $0.sentence == sentence })
    }

    var dailyCumulativeCount: [DailyCumulativeCount] {
        let calendar = Calendar.current

        // Group definitions by the day they were created
        var dailyCounts: [Date: Int] = [:]
        for def in definitions {
            // Round the date down to midnight
            let startOfDay = calendar.startOfDay(for: def.creationDate)
            dailyCounts[startOfDay, default: 0] += 1
        }

        // Sort the days
        let sortedDays = dailyCounts.keys.sorted()

        // Build an array of DailyCumulativeCount with a running total
        var cumulativeData: [DailyCumulativeCount] = []
        var runningTotal = 0
        for day in sortedDays {
            runningTotal += (dailyCounts[day] ?? 0)
            cumulativeData.append(DailyCumulativeCount(date: day, cumulativeCount: runningTotal))
        }

        return cumulativeData
    }
}

struct DailyCumulativeCount: Identifiable {
    let id = UUID()
    let date: Date
    let cumulativeCount: Int
}
