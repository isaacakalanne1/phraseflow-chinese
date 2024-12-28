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

    func dailyCumulativeCount(from definitions: [Definition]) -> [DailyCumulativeCount] {
        var filteredDefinitions: [Definition] = []
        for def in definitions {
            if !filteredDefinitions.contains(where: { $0.timestampData.word == def.timestampData.word }) {
                filteredDefinitions.append(def)
            }
        }
        let calendar = Calendar.current

        // Group definitions by the day they were created
        var dailyCounts: [Date: Int] = [:]
        for def in filteredDefinitions {
            // Round the date down to midnight
            let startOfDay = calendar.startOfDay(for: def.creationDate)
            dailyCounts[startOfDay, default: 0] += 1
        }

        // Sort the days chronologically
        let sortedDays = dailyCounts.keys.sorted()

        // Build an array of DailyCumulativeCount with a running total
        var cumulativeData: [DailyCumulativeCount] = []
        var runningTotal = 0

        for day in sortedDays {
            runningTotal += (dailyCounts[day] ?? 0)
            cumulativeData.append(DailyCumulativeCount(date: day, cumulativeCount: runningTotal))
        }

        // --- NEW CODE: Insert a data point for the day before the earliest day ---
        if let earliestDay = sortedDays.first {
            // "Day before" earliest day
            if let dayBeforeEarliest = calendar.date(byAdding: .day, value: -1, to: earliestDay) {
                // Insert at the beginning with a cumulative count of 0
                cumulativeData.insert(
                    DailyCumulativeCount(date: dayBeforeEarliest, cumulativeCount: 0),
                    at: 0
                )
            }
        }

        return cumulativeData
    }

}

struct DailyCumulativeCount: Identifiable {
    let id = UUID()
    let date: Date
    let cumulativeCount: Int
}
