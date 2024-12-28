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

    var body: some View {
        Chart(store.state.definitionState.dailyCumulativeCount) { dataPoint in
            LineMark(
                x: .value("Date", dataPoint.date),
                y: .value("Cumulative Definitions", dataPoint.cumulativeCount)
            )
            // You could also add a symbol to each data point:
            // .symbol(Circle())
        }
        .chartXAxis {
            // Format the x-axis as needed, for example just day/month:
            AxisMarks(values: .stride(by: .day)) { value in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.day().month(.abbreviated))
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .padding()
        .navigationTitle("Cumulative Definitions")
    }
}
