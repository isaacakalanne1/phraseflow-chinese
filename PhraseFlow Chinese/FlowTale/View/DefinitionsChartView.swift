//
//  DefinitionsChartView.swift
//  FlowTale
//
//  Created by iakalann on 28/12/2024.
//

import SwiftUI
import Charts

// MARK: - Main View
struct DefinitionsChartView: View {
    @EnvironmentObject var store: FlowTaleStore  // Replace with your own logic
    let definitions: [Definition]
    let isCreations: Bool

    var body: some View {
        // 1) Compute dailyCumulativeCount. You might do this in your store or here:
        // Example: let dailyCumulativeCount = makeDailyCumulativeCount(from: definitions)
        // But in your code, you said you have:
        let dailyCumulativeCount = store.state.definitionState.dailyCreationAndStudyCumulative(from: definitions)

        // 2) Get the maximum cumulative count
        let maxCount = dailyCumulativeCount
            .map { isCreations ? $0.cumulativeCreations : $0.cumulativeStudied }
            .max() ?? 0

        // 3) Determine up to two "next checkpoints"
        let upcomingCheckpoints = checkpoints(for: maxCount)  // see below
        // Example result: [ (400, "Intermediate"), (1000, "Advanced") ]

        // 4) Calculate the Y-axis domain max
        let yMax: Double
        if let highestCheckpoint = upcomingCheckpoints.map(\.value).max() {
            // If we have future checkpoints, show at least the highest + 10
            yMax = Double(highestCheckpoint + 10)
        } else {
            // Otherwise just scale to maxCount + 10
            yMax = Double(maxCount + 10)
        }

        // 5) Build the Chart
        return Chart {
            // -- Plot the dailyCumulativeCount data
            ForEach(dailyCumulativeCount, id: \.date) { dataPoint in
                LineMark(
                    x: .value("Date", dataPoint.date),
                    y: .value((isCreations ? "Saved Definitions" : "Studied Words"),
                              (isCreations ? dataPoint.cumulativeCreations : dataPoint.cumulativeStudied))
                )
                .interpolationMethod(.linear)
                .foregroundStyle(
                    FlowTaleColor.accent
                )

                // -- Add a light fill under the line
                AreaMark(
                    x: .value("Date", dataPoint.date),
                    y: .value((isCreations ? "Saved Definitions" : "Studied Words"),
                              (isCreations ? dataPoint.cumulativeCreations : dataPoint.cumulativeStudied))
                )
                .foregroundStyle(
                    FlowTaleColor.accent.opacity(0.2).gradient
                )
            }

            // -- Draw each upcoming checkpoint with a dashed line
            ForEach(upcomingCheckpoints, id: \.value) { checkpoint in
                RuleMark(
                    y: .value("Checkpoint", checkpoint.value)
                )
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5])) // dotted line
                .foregroundStyle(FlowTaleColor.secondary)
                .annotation(position: .top, alignment: .leading) {
                    Text(checkpoint.label)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        // -- Adjust the Y-axis domain to show everything
        .chartYScale(domain: 0...yMax)

        // -- Axis Labels
//        .chartXAxisLabel("Date", position: .bottom, alignment: .center)
//        .chartYAxisLabel("Learned words", position: .leading)

        // -- Format the X-axis
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { value in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.day().month(.abbreviated))
            }
        }

        // -- Format the Y-axis
        .chartYAxis {
            AxisMarks(position: .leading)
        }

        .padding()
    }

    // MARK: - Next Two Checkpoints Logic
    /// Returns up to two upcoming checkpoints based on the user's current maxCount.
    ///
    /// - If maxCount < 400 => returns [ (400, "Intermediate"), (1000, "Advanced") ]
    /// - If 400 <= maxCount < 1000 => returns [ (1000, "Advanced"), (2000, "Expert") ]
    /// - If 1000 <= maxCount < 2000 => returns [ (2000, "Expert") ]
    /// - If maxCount >= 2000 => returns []
    private func checkpoints(for maxCount: Int) -> [(value: Int, label: String)] {
        let allCheckpoints = [
            (value: 400,  label: "Intermediate"),
            (value: 1000, label: "Advanced"),
            (value: 2000, label: "Expert")
        ]

        // Find the first checkpoint that is strictly above the user's max
        guard let firstIndex = allCheckpoints.firstIndex(where: { $0.value > maxCount }) else {
            // If none are above maxCount, return empty
            return []
        }

        // Return that checkpoint plus the next one (if it exists)
        var result: [(Int, String)] = []
        result.append(allCheckpoints[firstIndex])

        let nextIndex = firstIndex + 1
        if allCheckpoints.indices.contains(nextIndex) {
            result.append(allCheckpoints[nextIndex])
        }

        return result
    }
}
