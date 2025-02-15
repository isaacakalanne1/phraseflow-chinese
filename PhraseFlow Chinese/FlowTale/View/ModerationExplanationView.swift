//
//  ModerationExplanationView.swift
//  FlowTale
//
//  Created by iakalann on 19/01/2025.
//

import SwiftUI

struct ModerationExplanationView: View {
    @EnvironmentObject var store: FlowTaleStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading) {
                Text(LocalizedString.storyDidNotPassModeration)
                    .lineLimit(0)
                    .font(.title)
                    .fontWeight(.semibold)

                Text(store.state.settingsState.customPrompt)
                    .font(.footnote)
                    .fontWeight(.light)

                Divider()

                Text(LocalizedString.whatIsModeration)
                    .font(.title2)
                    .fontWeight(.medium)
                Text(LocalizedString.moderationExplanation)
                    .font(.footnote)
                    .fontWeight(.light)

                Divider()

                Text(LocalizedString.howDoesModerationWork)
                    .font(.title2)
                    .fontWeight(.medium)
                Text(LocalizedString.moderationWorkExplanation)
                    .font(.footnote)
                    .fontWeight(.light)

                Divider()

                Text(LocalizedString.whyDidntItPass)
                    .font(.title2)
                    .fontWeight(.medium)

                Divider()

                // Show each category’s pass/fail
                ScrollView {
                    if let moderationResponse = store.state.moderationResponse {
                        ForEach(moderationResponse.categoryResults.sorted(by: { !$0.didPass && $1.didPass })) { result in
                            HStack {
                                if result.didPass {
                                    Text("✅ \(result.category.name)")
                                        .foregroundColor(.green)
                                } else {
                                    Text("❌ \(result.category.name)")
                                        .foregroundColor(.red)
                                }

                                Spacer()

                                // Example text:
                                // "We accept below 80% | You scored 92%"
                                VStack(alignment: .trailing) {
                                    Text(LocalizedString.acceptanceThresholdExplanation("\(result.thresholdPercentageString)"))
                                         Text(LocalizedString.userScoreExplanation("\(result.scorePercentageString)"))
                                        .bold(!result.didPass)
                                }
                                .font(.footnote)
                                .foregroundColor(.secondary)
                            }
                            .padding(.bottom)
                        }
                    }
                }
            }

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
