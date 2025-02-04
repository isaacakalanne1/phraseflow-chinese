//
//  DailyLimitExplanationView.swift
//  FlowTale
//
//  Created by iakalann on 19/01/2025.
//

import SwiftUI

struct DailyLimitExplanationView: View {
    @EnvironmentObject var store: FlowTaleStore
    @Environment(\.dismiss) private var dismiss

    var title: String {
        if let limit = store.state.subscriptionState.currentSubscription?.chapterLimitPerDay {
            return "You have reached your daily limit of \(limit) chapters"
        }
        return "You have reached your daily limit of chapters"
    }

    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading) { // TODO: Localize
                Text(title)
                    .lineLimit(0)
                    .font(.title)
                    .fontWeight(.semibold)

                Text(store.state.settingsState.customPrompt)
                    .font(.footnote)
                    .fontWeight(.light)

                Divider()

                Text("What happened?")
                    .font(.title2)
                    .fontWeight(.medium)
                Text("You have reached your daily limit for creating chapters.")
                    .font(.footnote)
                    .fontWeight(.light)

                Text("When can I create more?")
                    .font(.title2)
                    .fontWeight(.medium)
                Text("You can create more chaptrs in \(store.state.subscriptionState.nextAvailableDescription)")
                    .font(.footnote)
                    .fontWeight(.light)

                Divider()

                Text("Why is there a daily limit?")
                    .font(.title2)
                    .fontWeight(.medium)
                Text("The text to speech AI is really expensive.\nIf we let users create infinite chapters, we would go bankrupt.\nOur daily limit gives you the most stories possible without risking us going bankrupt.")
                    .font(.footnote)
                    .fontWeight(.light)

                // TODO: Add logic to show which chapter creation dates used free trial

//                Divider()
//
//                Text("Which stories did I create today?")
//                    .font(.title2)
//                    .fontWeight(.medium)
//
//                Divider()
//
//                // Show each category’s pass/fail
//                ScrollView {
//                    if let moderationResponse = store.state.moderationResponse {
//                        ForEach(moderationResponse.categoryResults.sorted(by: { !$0.didPass && $1.didPass })) { result in
//                            HStack {
//                                if result.didPass {
//                                    Text("✅ \(result.category.name)")
//                                        .foregroundColor(.green)
//                                } else {
//                                    Text("❌ \(result.category.name)")
//                                        .foregroundColor(.red)
//                                }
//
//                                Spacer()
//
//                                // Example text:
//                                // "We accept below 80% | You scored 92%"
//                                VStack(alignment: .trailing) {
//                                    Text(LocalizedString.acceptanceThresholdExplanation("\(result.thresholdPercentageString)"))
//                                         Text(LocalizedString.userScoreExplanation("\(result.scorePercentageString)"))
//                                        .bold(!result.didPass)
//                                }
//                                .font(.footnote)
//                                .foregroundColor(.secondary)
//                            }
//                            .padding(.bottom)
//                        }
//                    }
//                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            PrimaryButton(title: LocalizedString.okayButton) {
                dismiss()
            }
        }
        .padding()
        .navigationTitle(LocalizedString.navigationTitleWhy)
        .navigationBarTitleDisplayMode(.inline)
        .background(FlowTaleColor.background)
    }
}
