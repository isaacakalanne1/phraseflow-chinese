//
//  DefinitionsChartView.swift
//  FlowTale
//
//  Created by iakalann on 28/12/2024.
//

import SwiftUI
import Charts

struct DefinitionsChartView: View {
    @EnvironmentObject var store: FlowTaleStore
    let definitions: [Definition]

    // MARK: - Body
    var body: some View {
        let dailyCumulativeCount = store.state.definitionState.dailyCumulativeCount(from: definitions)
        // 1) Determine max cumulative count
        let maxCount = dailyCumulativeCount
            .map { $0.cumulativeCount }
            .max() ?? 0

        // 2) Figure out the next checkpoint + Y-axis domain
        let checkpoint = nextCheckpoint(for: maxCount)
        // e.g. (value: 400, label: "Intermediate", domainMax: 410)

        // If we have a checkpoint, use its domainMax. Otherwise just go to maxCount + 10
        let yMax = Double(checkpoint?.domainMax ?? maxCount + 10)

        Chart {
            // -- The line itself
            ForEach(dailyCumulativeCount, id: \.date) { dataPoint in
                LineMark(
                    x: .value("Date", dataPoint.date),
                    y: .value("Cumulative Definitions", dataPoint.cumulativeCount)
                )
                .interpolationMethod(.cardinal)

                // -- Add a light fill under the line
                AreaMark(
                    x: .value("Date", dataPoint.date),
                    y: .value("Cumulative Definitions", dataPoint.cumulativeCount)
                )
                .foregroundStyle(
                    // Pick a color you like
                    // You might also consider a gradient: .linearGradient(colors: [...], startPoint:..., endPoint:...)
                    Color.blue.opacity(0.2).gradient
                )
            }

            // -- If there's a next checkpoint, draw a horizontal dotted line
            if let checkpoint = checkpoint {
                RuleMark(
                    y: .value("Checkpoint", checkpoint.value)
                )
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                .foregroundStyle(.gray)
                .annotation(position: .top, alignment: .leading) {
                    Text(checkpoint.label)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        // -- Set the Y-axis domain
        .chartYScale(domain: 0 ... yMax)

        // -- Axis labels
        .chartXAxisLabel("Date",
                         position: .bottom,
                         alignment: .center)
        .chartYAxisLabel("Learned words",
                         position: .leading)

        // -- Format the X-axis (optional)
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

    // MARK: - Next Checkpoint Logic
    /// Returns the "next" checkpoint based on the user's current max count.
    ///
    /// - If max < 400 => next checkpoint is 400 (Intermediate), domain => 410
    /// - If max < 1000 => next checkpoint is 1000 (Advanced), domain => 1010
    /// - If max < 2000 => next checkpoint is 2000 (Expert), domain => 2010
    /// - Otherwise => `nil` (no checkpoint line), and we just scale the axis to max+10
    private func nextCheckpoint(for maxCount: Int)
    -> (value: Int, label: String, domainMax: Int)? {
        if maxCount < 400 {
            return (400, "Intermediate", 410)
        } else if maxCount < 1000 {
            return (1000, "Advanced", 1010)
        } else if maxCount < 2000 {
            return (2000, "Expert", 2010)
        } else {
            return nil
        }
    }
}
